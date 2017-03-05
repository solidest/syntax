##
# LR parser generated by the Syntax tool.
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
#     --mode <parsing-mode> \
#     --output ~/ParserClassName.rb
##

class YYParse
  @@productions = {{{PRODUCTIONS}}}
  @@tokens = {{{TOKENS}}}
  @@table = {{{TABLE}}}

  @@stack = []
  @@__ = nil
  @@__loc = nil

  @@should_capture_locations = {{{CAPTURE_LOCATIONS}}}

  @@callbacks = {
    :on_parse_begin => nil,
    :on_parse_end => nil
  }

  EOF = '$'

  @@yytext = ''
  @@yyleng = 0

  def self.yyloc(s, e)
    # Epsilon doesn't produce location.
    if (!s || !e)
      return e if !s else s
    end

    return {
      :start_offset => s[:start_offset],
      :end_offset => e[:end_offset],
      :start_line => s[:start_line],
      :end_line => e[:end_line],
      :start_column => s[:start_column],
      :end_column => e[:end_column],
    }
  end

  def self.__=(__)
    @@__ = __
  end

  def self.__loc=(__loc)
    @@__loc = __loc
  end

  def self.__loc
    @@__loc
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

    @@stack = [0]

    token = tokenizer.get_next_token
    shifted_token = nil

    loop do
      if not token
        self.unexpected_end_of_input
      end

      state = @@stack[-1]
      column = @@tokens[token[:type]]

      if !@@table[state].has_key?(column)
        self.unexpected_token(token)
      end

      entry = @@table[state][column]

      if entry[0, 1] == 's'
        loc = nil
        if @@should_capture_locations
          loc = {
            :start_offset => token[:start_offset],
            :end_offset => token[:end_offset],
            :start_line => token[:start_line],
            :end_line => token[:end_line],
            :start_column => token[:start_column],
            :end_column => token[:end_column],
          }
        end

        @@stack.push(
          {
            :symbol => @@tokens[token[:type]],
            :semantic_value => token[:value],
            :loc => loc,
          },
          entry[1..-1].to_i
        )
        shifted_token = token
        token = tokenizer.get_next_token
      elsif entry[0, 1] == 'r'
        production_number = entry[1..-1].to_i
        production = @@productions[production_number]
        has_semantic_action = production.count > 2
        semantic_value_args = nil
        location_args = nil

        if has_semantic_action
          semantic_value_args = []

          if @@should_capture_locations
            location_args = []
          end
        end

        if production[1] != 0
          rhs_length = production[1]
          while rhs_length > 0
            rhs_length -= 1
            @@stack.pop
            stack_entry = @@stack.pop
            if has_semantic_action
              semantic_value_args.unshift(stack_entry[:semantic_value])

              if @@should_capture_locations
                location_args.unshift(stack_entry[:loc])
              end
            end
          end
        end

        reduce_stack_entry = {:symbol => production[0]}

        if has_semantic_action
          @@yytext = shifted_token ? shifted_token[:value] : nil
          @@yyleng = shifted_token ? shifted_token[:value].length : nil

          semantic_action_args = semantic_value_args

          if @@should_capture_locations
            semantic_action_args += location_args
          end

          YYParse.send(production[2], *semantic_action_args)
          reduce_stack_entry[:semantic_value] = @@__

          if @@should_capture_locations
            reduce_stack_entry[:loc] = @@__loc
          end
        end

        next_state = @@stack[-1]
        symbol_to_reduce_with = production[0].to_s

        @@stack.push(
          reduce_stack_entry,
          @@table[next_state][symbol_to_reduce_with]
        )

      elsif entry == 'acc'
        @@stack.pop
        parsed = @@stack.pop

        if @@stack.length != 1 || @@stack[0] != 0 || tokenizer.has_more_tokens
          self.unexpected_token(token)
        end

        parsed_value = parsed.has_key?(:semantic_value) ? parsed[:semantic_value] : true

        if (@@callbacks[:on_parse_end])
          @@callbacks[:on_parse_end].call(parsed_value)
        end

        return parsed_value
      end

      if not tokenizer.has_more_tokens and @@stack.length <= 1
        break
      end
    end
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
    raise 'SyntaxError: ' + message
  end
end

{{{MODULE_INCLUDE}}}

{{{TOKENIZER}}}

class {{{PARSER_CLASS_NAME}}} < YYParse; end
