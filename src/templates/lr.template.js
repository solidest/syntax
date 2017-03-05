/**
 * LR parser generated by the Syntax tool.
 *
 * https://www.npmjs.com/package/syntax-cli
 *
 *   npm install -g syntax-cli
 *
 *   syntax-cli --help
 *
 * To regenerate run:
 *
 *   syntax-cli \
 *     --grammar ~/path-to-grammar-file \
 *     --mode <parsing-mode> \
 *     --output ~/path-to-output-parser-file.js
 */

'use strict';

/**
 * Matched token text.
 */
let yytext;

/**
 * Length of the matched token text.
 */
let yyleng;

/**
 * Storage object.
 */
let yy = {};

/**
 * Result of semantic action.
 */
let __;

/**
 * Result location object.
 */
let __loc;

function yyloc(start, end) {
  // Epsilon doesn't produce location.
  if (!start || !end) {
    return start || end;
  }

  return {
    startOffset: start.startOffset,
    endOffset: end.endOffset,
    startLine: start.startLine,
    endLine: end.endLine,
    startColumn: start.startColumn,
    endColumn: end.endColumn,
  };
}

let shouldCaptureLocations = {{{CAPTURE_LOCATIONS}}};

const EOF = '$';

/**
 * List of productions (generated by Syntax tool).
 */
const productions = {{{PRODUCTIONS}}};

/**
 * Encoded tokens map.
 */
const tokens = {{{TOKENS}}};

/**
 * Parsing table (generated by Syntax tool).
 */
const table = {{{TABLE}}};

/**
 * Parsing stack.
 */
const stack = [];

/**
 * Tokenizer instance.
 */
let tokenizer;
{{{TOKENIZER}}}

/**
 * Expose tokenizer so it can be accessed in semantic actions.
 */
yy.lexer = tokenizer;
yy.tokenizer = tokenizer;

/**
 * Parsing module.
 */
const yyparse = {
  parse(string) {
    yyparse.onParseBegin(string);

    if (!tokenizer) {
      throw new Error(`Tokenizer instance wasn't specified.`);
    }

    tokenizer.initString(string);

    stack.length = 0;
    stack.push(0);

    let token = tokenizer.getNextToken();
    let shiftedToken = null;

    do {
      if (!token) {
        unexpectedEndOfInput();
      }

      let state = stack[stack.length - 1];
      let column = tokens[token.type];

      if (!table[state].hasOwnProperty(column)) {
        unexpectedToken(token);
      }

      let entry = table[state][column];

      // Shift action.
      if (entry[0] === 's') {
        let loc = null;

        if (shouldCaptureLocations) {
          loc = {
            startOffset: token.startOffset,
            endOffset: token.endOffset,
            startLine: token.startLine,
            endLine: token.endLine,
            startColumn: token.startColumn,
            endColumn: token.endColumn,
          };
        }

        stack.push(
          {symbol: tokens[token.type], semanticValue: token.value, loc},
          Number(entry.slice(1))
        );
        shiftedToken = token;
        token = tokenizer.getNextToken();
      }

      // Reduce action.
      else if (entry[0] === 'r') {
        let productionNumber = entry.slice(1);
        let production = productions[productionNumber];
        let hasSemanticAction = typeof production[2] === 'function';
        let semanticValueArgs = hasSemanticAction ? [] : null;

        const locationArgs = (
          hasSemanticAction && shouldCaptureLocations
            ? []
            : null
        );

        if (production[1] !== 0) {
          let rhsLength = production[1];
          while (rhsLength-- > 0) {
            stack.pop();
            let stackEntry = stack.pop();

            if (hasSemanticAction) {
              semanticValueArgs.unshift(stackEntry.semanticValue);

              if (locationArgs) {
                locationArgs.unshift(stackEntry.loc);
              }
            }
          }
        }

        const reduceStackEntry = {symbol: production[0]};

        if (hasSemanticAction) {
          yytext = shiftedToken ? shiftedToken.value : null;
          yyleng = shiftedToken ? shiftedToken.value.length : null;

          const semanticActionArgs = (
            locationArgs !== null
              ? semanticValueArgs.concat(locationArgs)
              : semanticValueArgs
          );

          production[2](...semanticActionArgs);

          reduceStackEntry.semanticValue = __;

          if (locationArgs) {
            reduceStackEntry.loc = __loc;
          }
        }

        const nextState = stack[stack.length - 1];
        const symbolToReduceWith = production[0];

        stack.push(
          reduceStackEntry,
          table[nextState][symbolToReduceWith]
        );
      }

      // Accept.
      else if (entry === 'acc') {
        stack.pop();
        let parsed = stack.pop();

        if (stack.length !== 1 ||
            stack[0] !== 0 ||
            tokenizer.hasMoreTokens()) {
          unexpectedToken(token);
        }

        if (parsed.hasOwnProperty('semanticValue')) {
          yyparse.onParseEnd(parsed.semanticValue);
          return parsed.semanticValue;
        }

        yyparse.onParseEnd();
        return true;
      }

    } while (tokenizer.hasMoreTokens() || stack.length > 1);
  },

  setTokenizer(customTokenizer) {
    tokenizer = customTokenizer;
    return yyparse;
  },

  getTokenizer() {
    return tokenizer;
  },

  onParseBegin(string) {},
  onParseEnd(parsed) {},
};

{{{MODULE_INCLUDE}}}

function unexpectedToken(token) {
  if (token.type === EOF) {
    unexpectedEndOfInput();
  }

  tokenizer.throwUnexpectedToken(
    token.value,
    token.startLine,
    token.startColumn
  );
}

function unexpectedEndOfInput() {
  parseError(`Unexpected end of input.`);
}

function parseError(message) {
  throw new SyntaxError(message);
}

module.exports = yyparse;
