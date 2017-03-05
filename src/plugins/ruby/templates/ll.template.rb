##
# LL(1) parser generated by the Syntax tool.
#
# https://www.npmjs.com/package/syntax-cli
#
#   npm install -g syntax-cli
#
#   syntax-cli --help
#
# To regenerate run:
#
#   syntax-cli \
#     --grammar ~/path-to-grammar-file \
#     --mode LL1 \
#     --output ~/ParserClassName.rb
##

class YYParse
  @@ps = {{{PRODUCTIONS}}}
  @@tks = {{{TOKENS}}}
  @@tbl = {{{TABLE}}}

  @@s = []
  @@__ = nil

  @@callbacks = {
    :on_parse_begin => nil,
    :on_parse_end => nil
  }

  EOF = '$'

  @@yytext = ''
  @@yyleng = 0

  def self.__=(__)
    @@__ = __
  end

  def self.yytext=(yytext)
    @@yytext = yytext
  end

  def self.yytext
    @@yytext
  end

  def self.yyleng=(yyleng)
    @@yyleng = yyleng
  end

  def self.yyleng
    @@yyleng
  end

  @@tokenizer = nil

  {{{PRODUCTION_HANDLERS}}}

  def self.tokenizer=(tokenizer)
    @@tokenizer = tokenizer
  end

  def self.tokenizer
    @@tokenizer
  end

  def self.on_parse_begin(&callback)
    @@callbacks[:on_parse_begin] = callback
  end

  def self.on_parse_end(&callback)
    @@callbacks[:on_parse_end] = callback
  end

  def self.parse(string)
    if (@@callbacks[:on_parse_begin])
      @@callbacks[:on_parse_begin].call(string)
    end

    tokenizer = self.tokenizer

    if not tokenizer
      raise "Tokenizer instance wasn't specified."
    end

    tokenizer.init_string(string)

    @@s = [self::EOF, {{{START}}}]

    t = tokenizer.get_next_token
    st = nil

    to = nil
    tt = nil

    loop do
      to = @@s.pop
      tt = @@tks[t[:type]]

      if to == tt
        t = tokenizer.get_next_token
        next
      end

      self.der(to, t, tt)

      if not tokenizer.has_more_tokens and @@s.length <= 1
        break
      end
    end

    while @@s.length != 1
      self.der(@@s.length, t, tt)
    end

    if @@s[0] != self::EOF || t[:type] != self::EOF
      self.parse_error('stack is not empty');
    end

    return true;
  end

  def self.der(to, t, tt)
    npn = @@tbl[to.to_s][tt.to_s]
    if not npn
      self.unexpected_token(t)
    end
    @@s.push(*@@ps[npn.to_i][0])
  end

  def self.unexpected_token(token)
    if token[:type] == self::EOF
      self.unexpected_end_of_input()
    end

    self.tokenizer.throw_unexpected_token(
      token[:value],
      token[:start_line],
      token[:start_column]
    )
  end

  def self.unexpected_end_of_input
    self.parse_error('Unexpected end of input.')
  end

  def self.parse_error(message)
    raise 'Parse error: ' + message
  end
end

{{{MODULE_INCLUDE}}}

{{{TOKENIZER}}}

class {{{PARSER_CLASS_NAME}}} < YYParse; end
