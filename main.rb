# frozen_string_literal: true

require 'redcarpet'
require_relative 'renderer'

markdown = Redcarpet::Markdown.new(Redcarpet::Render::LaTeX, fenced_code_blocks: true, lax_spacing: true, footnotes: true, quote: true, tables: true)
latex = markdown.render($stdin.read)
puts latex
