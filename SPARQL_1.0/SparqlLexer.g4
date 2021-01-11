/*
 * Copyright 2007 the original author or authors.
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following
 * conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following
 * disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
 * disclaimer in the documentation and/or other materials provided with the distribution.
 *
 * Neither the name of the author or authors nor the names of its contributors may be used to endorse or promote
 * products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @author Simone Tripodi   (simone)
 * @author Michele Mostarda (michele)
 * @version $Id: Sparql.g 5 2007-10-30 17:20:36Z simone $
 */
 /*
 * Ported to Antlr4 by Tom Everett
 */
lexer grammar SparqlLexer;

// $<Lexer

IRI_REF
    : '<' ( ~('<' | '>' | '"' | '{' | '}' | '|' | '^' | '\\' | '`') | (PN_CHARS))* '>'
    ;

PNAME_NS
    : PN_PREFIX? ':'
    ;

PNAME_LN
    : PNAME_NS PN_LOCAL
    ;

BLANK_NODE_LABEL
    : '_:' PN_LOCAL
    ;

VAR1
    : '?' VARNAME
    ;

VAR2
    : '$' VARNAME
    ;

LANGTAG
    : '@' PN_CHARS_BASE+ ('-' (PN_CHARS_BASE DIGIT)+)*
    ;

INTEGER
    : DIGIT+
    ;

DECIMAL
    : DIGIT+ '.' DIGIT*
    | '.' DIGIT+
    ;

DOUBLE
    : DIGIT+ '.' DIGIT* EXPONENT
    | '.' DIGIT+ EXPONENT
    | DIGIT+ EXPONENT
    ;

INTEGER_POSITIVE
    : '+' INTEGER
    ;

DECIMAL_POSITIVE
    : '+' DECIMAL
    ;

DOUBLE_POSITIVE
    : '+' DOUBLE
    ;

INTEGER_NEGATIVE
    : '-' INTEGER
    ;

DECIMAL_NEGATIVE
    : '-' DECIMAL
    ;

DOUBLE_NEGATIVE
    : '-' DOUBLE
    ;

EXPONENT
    : ('e'|'E') ('+'|'-')? DIGIT+
    ;

STRING_LITERAL1
    : '\'' ( ~('\u0027' | '\u005C' | '\u000A' | '\u000D') | ECHAR )* '\''
    ;

STRING_LITERAL2
    : '"'  ( ~('\u0022' | '\u005C' | '\u000A' | '\u000D') | ECHAR )* '"'
    ;

STRING_LITERAL_LONG1
    : '\'\'\'' ( ( '\'' | '\'\'' )? (~('\'' | '\\') | ECHAR ) )* '\'\'\''
    ;

STRING_LITERAL_LONG2
    : '"""' ( ( '"' | '""' )? ( ~('\'' | '\\') | ECHAR ) )* '"""'
    ;

ECHAR
    : '\\' ('t' | 'b' | 'n' | 'r' | 'f' | '"' | '\'')
    ;

NIL
    : '(' WS* ')'
    ;

ANON
    : '[' WS* ']'
    ;

PN_CHARS_U
    : PN_CHARS_BASE | '_'
    ;

VARNAME
    : ( PN_CHARS_U | DIGIT ) ( PN_CHARS_U | DIGIT | '\u00B7' | ('\u0300'..'\u036F') | ('\u203F'..'\u2040') )*
    ;

fragment
PN_CHARS
    : PN_CHARS_U
    | '-'
    | DIGIT
    /*| '\u00B7'
    | '\u0300'..'\u036F'
    | '\u203F'..'\u2040'*/
    ;

PN_PREFIX
    : PN_CHARS_BASE ((PN_CHARS|'.')* PN_CHARS)?
    ;

PN_LOCAL
    : ( PN_CHARS_U | DIGIT ) ((PN_CHARS|'.')* PN_CHARS)?
    ;

fragment
PN_CHARS_BASE
    : 'A'..'Z'
    | 'a'..'z'
    | '\u00C0'..'\u00D6'
    | '\u00D8'..'\u00F6'
    | '\u00F8'..'\u02FF'
    | '\u0370'..'\u037D'
    | '\u037F'..'\u1FFF'
    | '\u200C'..'\u200D'
    | '\u2070'..'\u218F'
    | '\u2C00'..'\u2FEF'
    | '\u3001'..'\uD7FF'
    | '\uF900'..'\uFDCF'
    | '\uFDF0'..'\uFFFD'
    ;

fragment
DIGIT
    : '0'..'9'
    ;

WS
    : (' '
    | '\t'
    | '\n'
    | '\r')+ ->skip
    ;


// $>
