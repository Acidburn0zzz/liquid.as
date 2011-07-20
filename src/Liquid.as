/**
 * Copyright (c) 2005 Tobias Luetke
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package {
  import flash.display.Sprite;

  public class Liquid extends Sprite {
    public static const FilterSeparator:RegExp            = /\|/;
    public static const ArgumentSeparator:String          = ',';
    public static const FilterArgumentSeparator:String    = ':';
    public static const VariableAttributeSeparator:String = '.';
    public static const TagStart:RegExp                   = /\{\%/;
    public static const TagEnd:RegExp                     = /\%\}/;
    public static const VariableSignature:RegExp          = /\(?[\w\-\.\[\]]\)?/;
    public static const VariableSegment:RegExp            = /[\w\-]/;
    public static const VariableStart:RegExp              = /\{\{/;
    public static const VariableEnd:RegExp                = /\}\}/;
    public static const VariableIncompleteEnd:RegExp      = /\}\}?/;
    public static const QuotedString:RegExp               = /"[^"]*"|'[^']*'/;
                                                          /* /#{QuotedString}|(?:[^\s,\|'"]|#{QuotedString})+/ */
    public static const QuotedFragment:RegExp             = combineRegExp(QuotedString, "|(?:[^\\s,\\|'\"]|", QuotedString, ")+");
    public static const StrictQuotedFragment:RegExp       = /"[^"]+"|'[^']+'|[^\s,\|,\:,\,]+/;
                                                          /* /#{FilterArgumentSeparator}(?:#{StrictQuotedFragment})/; */
    public static const FirstFilterArgument:RegExp        = combineRegExp(FilterArgumentSeparator, "(?:", StrictQuotedFragment, ")");
                                                          /* /#{ArgumentSeparator}(?:#{StrictQuotedFragment})/; */
    public static const OtherFilterArgument:RegExp        = combineRegExp(ArgumentSeparator, "(?:", StrictQuotedFragment, ")");
                                                          /* /^(?:'[^']+'|"[^"]+"|[^'"])*#{FilterSeparator}(?:#{StrictQuotedFragment})(?:#{FirstFilterArgument}(?:#{OtherFilterArgument})*)?/; */
    public static const SpacelessFilter:RegExp            = combineRegExp("^(?:'[^']+'|\"[^\"]+\"|[^'\"])*", FilterSeparator, "(?:", StrictQuotedFragment, ")(?:", FirstFilterArgument, "(?:", OtherFilterArgument, ")*)?");
                                                          /* /(?:#{QuotedFragment}(?:#{SpacelessFilter})*)/; */
    public static const Expression:RegExp                 = combineRegExp("(?:", QuotedFragment, "(?:", SpacelessFilter, ")*)");
                                                          /* /(\w+)\s*\:\s*(#{QuotedFragment})/; */
    public static const TagAttributes:RegExp              = combineRegExp("(\\w+)\\s*\\:\\s*(", QuotedFragment, ")");
    public static const AnyStartingTag:RegExp             = /\{\{|\{\%/;
                                                          /* /#{TagStart}.*?#{TagEnd}|#{VariableStart}.*?#{VariableIncompleteEnd}/; */
    public static const PartialTemplateParser:RegExp      = combineRegExp(TagStart, ".*?", TagEnd, "|", VariableStart, ".*?", VariableIncompleteEnd);
                                                          /* /(#{PartialTemplateParser}|#{AnyStartingTag})/; */
    public static const TemplateParser:RegExp             = combineRegExp("(", PartialTemplateParser, "|", AnyStartingTag, ")");
                                                          /* /\[[^\]]+\]|#{VariableSegment}+\??/; */
    public static const VariableParser:RegExp             = combineRegExp("\\[[^\\]]+\\]|", VariableSegment, "+\\??");
    public static const LiteralShorthand:RegExp           = /^(?:\{\{\{\s?)(.*?)(?:\s*\}\}\})$/;

    public function Liquid() {
      trace(">> Liquid Instantiated!");
    }

    // TODO Belongs on RegExp
    // Combines strings and regular expressions in the same way ruby does;
    //  uses (?-mix:{regexp}) when inserting regexps
    public static function combineRegExp(... args):RegExp {
      var regExpString:String = '';
      for each (var item:* in args) {
        if (item is RegExp) {
          regExpString += '(?-mix:' + (item as RegExp).source + ')';
        } else {
          regExpString += new RegExp(item).source;
        }
      }
      return new RegExp(regExpString);
    }

    // TODO Belongs on String
    public static function scan(str:String, regExpOrString:*):Array {
      var regString:String = (regExpOrString is RegExp) ? (regExpOrString as RegExp).source : regExpOrString;
      var globalRegExp:RegExp = new RegExp(regString, "g");

      var results:Array = [];
      var result:Object = globalRegExp.exec(str);
      while (result != null) {
        results.push(result[result.length - 1]);
        result = globalRegExp.exec(str);
      }

      return results;
    }

    // TODO Belongs on String
    private static const Trim:RegExp = /(\A\s+|\s+\Z)/g;
    public static function trim(str:String):String {
      return str.replace(Liquid.Trim, '');
    }

    // TODO Belongs on Array
    public static function flatten(arr:Array):Array {
      var flattened:Array = [];
      for each (var item:* in arr) {
        if (item is Array) {
          flattened.push.apply(flattened, flatten(item));
        } else {
          flattened.push(item);
        }
      }
      return flattened;
    }
  }

  // TODO Would like to do something like this for all these helper functions
//  String.prototype.scan = function(pattern:*):Array {
//      var patternString:String = (pattern is RegExp) ? (pattern as RegExp).source : pattern;
//      return this.match(new RegExp(patternString, "g"));
//  }
}

