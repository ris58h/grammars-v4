/*
BSD License

Copyright (c) 2020, Tom Everett
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the name of Tom Everett nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
grammar turing;

program
   : declarationOrStatementInMainProgram*
   ;

declarationOrStatementInMainProgram
   : declaration
   | statement
   | subprogramDeclaration
   ;

declaration
   : constantDeclaration
   | variableDeclaration
   | typeDeclaration
   ;

constantDeclaration
   : ('const' id ':=' expn)
   | ('const' id '[' ':' typeSpec ']' ':=' initializingValue)
   ;

initializingValue
   : expn '(' 'init' (initializingValue (',' initializingValue)* ')')
   ;

variableDeclaration
   : ('var' id (',' id)* ':=' expn)
   | ('var' id (',' id)* ':' typeSpec '[' ':=' initializingValue ']')
   ;

typeDeclaration
   : 'type' id ':' typeSpec
   ;

typeSpec
   : standardType
   | subrangeType
   | arrayType
   | recordType
   | namedType
   ;

standardType
   : 'int'
   | 'real'
   | 'boolean'
   | 'string' ('(' compileTimeExpn ')')?
   ;

subrangeType
   : compileTimeExpn '..' expn
   ;

arrayType
   : 'array' indexType (',' indexType)* 'of' typeSpec
   ;

indexType
   : subrangeType
   | namedType
   ;

recordType
   : 'record' id (',' id)* ':' typeSpec (id (',' id)* ':' typeSpec)* 'end' 'record'
   ;

namedType
   : id
   ;

subprogramDeclaration
   : subprogramHeader subprogramBody
   ;

subprogramHeader
   : 'procedure' id ('(' parameterDeclaration (',' parameterDeclaration)* ')')? 'function' id ('(' parameterDeclaration (',' parameterDeclaration)* ')')? ':' typeSpec
   ;

parameterDeclaration
   : 'var'? id (',' id)* ':' parameterType
   ;

parameterType
   : ':' typeSpec
   | 'string' '(' '*' ')'
   | 'array' compileTimeExpn '..' '*' (',' compileTimeExpn '..' '*')* 'of' typeSpec
   | 'array' compileTimeExpn '..' '*' (',' compileTimeExpn '..' '*')* 'of' string '(' '*' ')'
   ;

subprogramBody
   : declarationsAndStatements 'end' id
   ;

declarationsAndStatements
   : declarationOrStatement*
   ;

declarationOrStatement
   : declaration
   | statement
   ;

statement
   : (variableReference ':=' expn)
   |
   | procedureCall
   | ('assert' booleanExpn)
   | 'result' expn
   | ifStatement
   | loopStatement
   | 'exit' ('when' booleanExpn)?
   | caseStatement
   | forStatement
   | putStatement
   | getStatement
   | openStatement
   | closeStatement
   ;

procedureCall
   : reference
   ;

ifStatement
   : 'if' booleanExpn 'then' declarationsAndStatements ('elsif' booleanExpn 'then' declarationsAndStatements)* ('else' declarationsAndStatements)? 'end' 'if'
   ;

loopStatement
   : 'loop' declarationsAndStatements 'end' 'loop'
   ;

caseStatement
   : 'case' expn 'of' 'label' compileTimeExpn (',' compileTimeExpn)* ':' declarationsAndStatements ('label' compileTimeExpn (',' compileTimeExpn)* ':' declarationsAndStatements)* ('label' ':' declarationsAndStatements)? 'end' 'case'
   ;

forStatement
   : ('for' id ':' expn '..' expn ('by' expn)? declarationsAndStatements 'end' 'for')
   | ('for' 'decreasing' id ':' expn '..' expn ('by' expn)? declarationsAndStatements 'end' 'for')
   ;

putStatement
   : 'put' (':' streamNumber ',')? 'putItem' (',' putItem)? ('..')?
   ;

putItem
   : expn (':' widthExpn (':' fractionWidth (' :' exponentWidth)?)?)?
   | 'skip'
   ;

getStatement
   : 'get' (':' streamNumber ',')? getItem (',' getItem)*
   ;

getItem
   : variableReference
   | 'skip' variableReference ':' '*'
   | variableReference ':' widthExpn
   ;

openStatement
   : 'open' ':' fileNumber ',' string ',' capability (',' capability)*
   ;

capability
   : 'get'
   | 'put'
   ;

closeStatement
   : 'close' ':' fileNumber
   ;

streamNumber
   : expn
   ;

widthExpn
   : expn
   ;

fractionWidth
   : expn
   ;

exponentWidth
   : expn
   ;

fileNumber
   : expn
   ;

variableReference
   : reference
   ;

reference
   : id
   | (reference componentSelector)
   ;

componentSelector
   : '(' expn (',' expn)* ')'
   | '.' id
   ;

booleanExpn
   : expn
   ;

compileTimeExpn
   : expn
   ;

expn
   : reference
   | explicitConstant
   | substring
   | expn infixOperator expn
   | prefixOperator expn
   | '(' expn ')'
   ;

string
   : ExplicitStringConstant
   ;

explicitConstant
   : ExplicitUnsignedIntegerConstant
   | ExplicitUnsignedRealConstant
   | ExplicitStringConstant
   | 'true'
   | 'false'
   ;

infixOperator
   : '+'
   | '–'
   | '*'
   | '/' 'div'
   | 'mod'
   | '**'
   | '<'
   | '>'
   | '='
   | '<='
   | '>='
   | 'not='
   | 'and'
   | 'or'
   ;

prefixOperator
   : '+'
   | '–'
   | 'not'
   ;

substring
   : reference '(' substringPosition ('..' substringPosition)? ')'
   ;

substringPosition
   : expn ('*' ('–' expn))
   ;

ExplicitUnsignedIntegerConstant
   : [0-9]+
   ;

ExplicitUnsignedRealConstant
   : ExplicitUnsignedIntegerConstant '.' ExplicitUnsignedIntegerConstant
   ;

ExplicitStringConstant
   : '"' ~ '"' '"'
   ;

id
   : IDENTIFIER
   ;

IDENTIFIER
   : [a-zA-Z] [a-zA-Z_0-9]*
   ;

WS
   : [ \r\n\t]+ -> skip
   ;

