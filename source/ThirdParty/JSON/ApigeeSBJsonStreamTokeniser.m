//
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ApigeeSBJsonStreamTokeniser.h"

#define SBStringIsIllegalSurrogateHighCharacter(character) (((character) >= 0xD800UL) && ((character) <= 0xDFFFUL))
#define SBStringIsSurrogateLowCharacter(character) ((character >= 0xDC00UL) && (character <= 0xDFFFUL))
#define SBStringIsSurrogateHighCharacter(character) ((character >= 0xD800UL) && (character <= 0xDBFFUL))

@implementation ApigeeSBJsonStreamTokeniser {
    NSMutableData *data;
    const char *bytes;
    NSUInteger index;
    NSUInteger offset;
}

- (void)setError:(NSString *)error {
    _error = [NSString stringWithFormat:@"%@ at index %lu", error, (unsigned long)(offset + index)];
}

- (void)appendData:(NSData *)data_ {
    if (!data) {
        data = [data_ mutableCopy];

    } else if (index) {
        // Discard data we've already parsed
        [data replaceBytesInRange:NSMakeRange(0, index) withBytes:"" length:0];
        [data appendData:data_];

        // Add to the offset for reporting
        offset += index;

        // Reset index to point to current position
        index = 0u;

    }
    else {
       [data appendData:data_];       
    }

    bytes = [data bytes];
}

- (void)skipWhitespace {
    while (index < data.length) {
        switch (bytes[index]) {
            case ' ':
            case '\t':
            case '\r':
            case '\n':
                index++;
            break;
            default:
                return;
        }
    }
}

- (BOOL)getUnichar:(unichar *)ch {
    if ([self haveRemainingCharacters:1]) {
        *ch = (unichar) bytes[index];
        return YES;
    }
    return NO;
}

- (BOOL)haveOneMoreCharacter {
    return [self haveRemainingCharacters:1];
}

- (BOOL)haveRemainingCharacters:(NSUInteger)length {
    return data.length - index >= length;
}

- (Apigee_sbjson_token_t)match:(char *)str retval:(Apigee_sbjson_token_t)tok token:(char **)token length:(NSUInteger *)length {
    NSUInteger len = strlen(str);
    if ([self haveRemainingCharacters:len]) {
        if (!memcmp(bytes + index, str, len)) {
            *token = str;
            *length = len;
            index += len;
            return tok;
        }
        [self setError: [NSString stringWithFormat:@"Expected '%s' after initial '%.1s'", str, str]];
        return Apigee_sbjson_token_error;
    }

    return Apigee_sbjson_token_eof;
}

- (BOOL)decodeHexQuad:(unichar*)quad {
    unichar tmp = 0;

    for (int i = 0; i < 4; i++, index++) {
        unichar c = bytes[index];
        tmp *= 16;
        switch (c) {
            case '0' ... '9':
                tmp += c - '0';
                break;

            case 'a' ... 'f':
                tmp += 10 + c - 'a';
                break;

            case 'A' ... 'F':
                tmp += 10 + c - 'A';
                break;

            default:
                return NO;
        }
    }
    *quad = tmp;
    return YES;
}

- (Apigee_sbjson_token_t)getStringToken:(char **)token length:(NSUInteger *)length {

    // Skip initial "
    index++;

    NSUInteger string_start = index;
    Apigee_sbjson_token_t tok = Apigee_sbjson_token_string;

    for (;;) {
        if (![self haveOneMoreCharacter])
            return Apigee_sbjson_token_eof;

        switch (bytes[index]) {
            case 0 ... 0x1F:
                [self setError:[NSString stringWithFormat:@"Unescaped control character [0x%0.2X] in string", bytes[index]]];
                return Apigee_sbjson_token_error;

            case '"':
                *token = (char *)(bytes + string_start);
                *length = index - string_start;
                index++;
                return tok;

            case '\\':
                tok = Apigee_sbjson_token_encoded;
                index++;
                if (![self haveOneMoreCharacter])
                    return Apigee_sbjson_token_eof;

                if (bytes[index] == 'u') {
                    index++;
                    if (![self haveRemainingCharacters:4])
                        return Apigee_sbjson_token_eof;

                    unichar hi;
                    if (![self decodeHexQuad:&hi]) {
                        [self setError:@"Invalid hex quad"];
                        return Apigee_sbjson_token_error;
                    }

                    if (SBStringIsSurrogateHighCharacter(hi)) {
                        if (![self haveRemainingCharacters:6])
                            return Apigee_sbjson_token_eof;

                        unichar lo;
                        if (bytes[index++] != '\\' || bytes[index++] != 'u' || ![self decodeHexQuad:&lo]) {
                            [self setError:@"Missing low character in surrogate pair"];
                            return Apigee_sbjson_token_error;
                        }

                        if (!SBStringIsSurrogateLowCharacter(lo)) {
                            [self setError:@"Invalid low character in surrogate pair"];
                            return Apigee_sbjson_token_error;
                        }

                    } else if (SBStringIsIllegalSurrogateHighCharacter(hi)) {
                        [self setError:@"Invalid high character in surrogate pair"];
                        return Apigee_sbjson_token_error;

                    }


                } else {
                    switch (bytes[index]) {
                        case '\\':
                        case '/':
                        case '"':
                        case 'b':
                        case 'n':
                        case 'r':
                        case 't':
                        case 'f':
                            index++;
                            break;

                        default:
                            [self setError:[NSString stringWithFormat:@"Illegal escape character [%x]", bytes[index]]];
                            return Apigee_sbjson_token_error;
                    }
                }

                break;

            default:
                index++;
                break;
        }
    }

    @throw @"FUT FUT FUT";
}

- (Apigee_sbjson_token_t)getNumberToken:(char **)token length:(NSUInteger *)length {
    NSUInteger num_start = index;
    if (bytes[index] == '-') {
        index++;

        if (![self haveOneMoreCharacter])
            return Apigee_sbjson_token_eof;
    }

    Apigee_sbjson_token_t tok = Apigee_sbjson_token_integer;
    if (bytes[index] == '0') {
        index++;

        if (![self haveOneMoreCharacter])
            return Apigee_sbjson_token_eof;

        if (isdigit(bytes[index])) {
            [self setError:@"Leading zero is illegal in number"];
            return Apigee_sbjson_token_error;
        }
    }

    while (isdigit(bytes[index])) {
        index++;
        if (![self haveOneMoreCharacter])
            return Apigee_sbjson_token_eof;
    }

    if (![self haveOneMoreCharacter])
        return Apigee_sbjson_token_eof;


    if (bytes[index] == '.') {
        index++;
        tok = Apigee_sbjson_token_real;

        if (![self haveOneMoreCharacter])
            return Apigee_sbjson_token_eof;

        NSUInteger frac_start = index;
        while (isdigit(bytes[index])) {
            index++;
            if (![self haveOneMoreCharacter])
                return Apigee_sbjson_token_eof;
        }

        if (frac_start == index) {
            [self setError:@"No digits after decimal point"];
            return Apigee_sbjson_token_error;
        }
    }

    if (bytes[index] == 'e' || bytes[index] == 'E') {
        index++;
        tok = Apigee_sbjson_token_real;

        if (![self haveOneMoreCharacter])
            return Apigee_sbjson_token_eof;

        if (bytes[index] == '-' || bytes[index] == '+') {
            index++;
            if (![self haveOneMoreCharacter])
                return Apigee_sbjson_token_eof;
        }

        NSUInteger exp_start = index;
        while (isdigit(bytes[index])) {
            index++;
            if (![self haveOneMoreCharacter])
                return Apigee_sbjson_token_eof;
        }

        if (exp_start == index) {
            [self setError:@"No digits in exponent"];
            return Apigee_sbjson_token_error;
        }

    }

    if (num_start + 1 == index && bytes[num_start] == '-') {
        [self setError:@"No digits after initial minus"];
        return Apigee_sbjson_token_error;
    }

    *token = (char *)(bytes + num_start);
    *length = index - num_start;
    return tok;
}


- (Apigee_sbjson_token_t)getToken:(char **)token length:(NSUInteger *)length {
    [self skipWhitespace];
    NSUInteger copyOfIndex = index;

    unichar ch;
    if (![self getUnichar:&ch])
        return Apigee_sbjson_token_eof;

    Apigee_sbjson_token_t tok;
    switch (ch) {
        case '{': {
            index++;
            tok = Apigee_sbjson_token_object_open;
            break;
        }
        case '}': {
            index++;
            tok = Apigee_sbjson_token_object_close;
            break;

        }
        case '[': {
            index++;
            tok = Apigee_sbjson_token_array_open;
            break;

        }
        case ']': {
            index++;
            tok = Apigee_sbjson_token_array_close;
            break;

        }
        case 't': {
            tok = [self match:"true" retval:Apigee_sbjson_token_bool token:token length:length];
            break;

        }
        case 'f': {
            tok = [self match:"false" retval:Apigee_sbjson_token_bool token:token length:length];
            break;

        }
        case 'n': {
            tok = [self match:"null" retval:Apigee_sbjson_token_null token:token length:length];
            break;

        }
        case ',': {
            index++;
            tok = Apigee_sbjson_token_value_sep;
            break;

        }
        case ':': {
            index++;
            tok = Apigee_sbjson_token_entry_sep;
            break;

        }
        case '"': {
            tok = [self getStringToken:token length:length];
            break;

        }
        case '-':
        case '0' ... '9': {
            tok = [self getNumberToken:token length:length];
            break;

        }
        case '+': {
            self.error = @"Leading + is illegal in number";
            tok = Apigee_sbjson_token_error;
            break;

        }
        default: {
            self.error = [NSString stringWithFormat:@"Illegal start of token [%c]", ch];
            tok = Apigee_sbjson_token_error;
            break;
        }
    }

    if (tok == Apigee_sbjson_token_eof) {
        // We ran out of bytes before we could finish parsing the current token.
        // Back up to the start & wait for more data.
        index = copyOfIndex;
    }

    return tok;
}

@end