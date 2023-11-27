# frozen_string_literal: true

require 'json'
require 'redcarpet'
require 'redcarpet/render_strip'

module Redcarpet
  module Render
    class LaTeX < StripDown
      def block_code(code, language)
        lang, filename = language&.split(':', 2) || ['text', nil]

        if filename
          <<~LATEX
            \\begin{sourceCode}{#{filename}}
            \\begin{minted}[fontsize=\\footnotesize]{#{lang}}
            #{code}\\end{minted}
            \\end{sourceCode}
          LATEX
        else
          <<~LATEX
            \\begin{sourceCodeN}
            \\begin{minted}[fontsize=\\footnotesize]{#{lang}}
            #{code}\\end{minted}
            \\end{sourceCodeN}
          LATEX
        end
      end

      def block_quote(quote)
        "\\begin{quote}\n#{quote.strip}\n\\end{quote}\n\n"
      end

      def footnotes(content)
        content
      end

      def footnote_def(content, number)
        "\\footnotetext[#{number}]{#{content.strip}}"
      end

      def header(text, header_level)
        macro = [nil, 'chapter', 'section', 'subsection', 'subsubsection', 'paragraph', 'subparagraph'][header_level]
        "\\#{macro}{#{text}}\n"
      end

      def hrule
        "\\\\noindent{\\color{gray}\\hrulefill}\n\n"
      end

      def list(contents, list_type)
        if list_type == :ordered
          <<~LATEX
            \\begin{enumerate}
            #{contents}\\end{enumerate}
          LATEX
        else
          <<~LATEX
            \\begin{itemize}
            #{contents}\\end{itemize}
          LATEX
        end
      end

      def list_item(text, _list_type)
        "\\item #{text}"
      end

      def paragraph(text)
        "#{text}\n\n"
      end

      def table(header, body)
        headers = header.strip.split("\n").map {|e| JSON.parse(e)}
        bodies = body.split("\n\n").map {|l| l.split("\n").map {|e| JSON.parse(e)}}
        alignments = headers.map {|e| e[1][0]}
        <<~LATEX
          \\begin{table}[htbp]\\centering
          \\begin{tabular}{#{alignments.join}}
          \\toprule
          #{headers.map {|e| e[0]}.join(' & ')} \\\\\\midrule
          #{bodies.map {|l| l.map(&:first).join(' & ')}.join(" \\\\\n")}
          \\bottomrule
          \\end{tabular}
          \\end{table}
        LATEX
      end

      def table_row(content)
        "#{content}\n"
      end

      def table_cell(content, alignment, header)
        "#{JSON.generate([content, alignment, header])}\n"
      end

      # span-level
      def autolink(link, _link_type)
        "\\url{#{link}}"
      end

      def codespan(code)
        "\\texttt{#{code}}"
      end

      def double_emphasis(text)
        "\\textbf{#{text}}"
      end

      def emphasis(text)
        "\\textit{#{text}}"
      end

      def image(link, _title, alt_text)
        if alt_text
          <<~LATEX
            \\begin{figure}[htbp]\\centering
            \\includegraphics[width=0.9\\linewidth]{#{link}}
            \\caption{#{alt_text}}\\end{figure}
          LATEX
        else
          <<~LATEX
            \\begin{figure}[htbp]\\centering
            \\includegraphics[width=0.9\\linewidth]{#{link}}
            \\end{figure}
          LATEX
        end
      end

      def linebreak
        "\n"
      end

      def link(link, _title, content)
        "#{content}\\footnote{\\url{#{link}}}"
      end

      def triple_emphasis(text)
        "\\textbf{\\textit{#{text}}}"
      end

      def strikethrough(text)
        "\\strikeThrough{#{text}}"
      end

      def superscript(text)
        "\\textsuperscript{#{text}}"
      end

      def underline(text)
        "\\underLine{#{text}}"
      end

      def quote(text)
        "``#{text}''"
      end

      def footnote_ref(number)
        "\\footnotemark[#{number}]"
      end

      def entity(text)
        escape_latex(text)
      end

      def normal_text(text)
        escape_latex(text)
      end

      def escape_latex(text)
        text.gsub(/([{}])/) {|match| "\\#{match}"}
            .gsub('\\', '\\textbackslash{}')
            .gsub('~', '\\textasciitilde{}')
            .gsub('^', '\\textasciicircum{}')
            .gsub(/([%&$#_])/) {|match| "\\#{match}"}
      end
    end
  end
end
