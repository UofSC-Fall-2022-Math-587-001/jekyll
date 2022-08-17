module Jekyll
  module Tags
    class Equation < Liquid::Block
      def initialize(tag_name, markup, tokens)
        super
        @file_name = markup.gsub(/\s+/, "")

        @header = <<-'END'
        \documentclass[14pt,border=2pt]{standalone}
        \usepackage{amsmath,amssymb,tikz-cd,tikz,braids,ebproof}

        \begin{document}
        $$
        \LARGE 
        END

        @footer = <<-'END'
        $$
        \end{document}
        END
      end

      def render(context)
        tex_code = @header + super + @footer
        alt_text = @file_name.gsub("_"," ")

        tmp_directory = File.join(Dir.pwd, "_tex_tmp", File.basename(context["page"]["url"], ".*"))
        tex_path = File.join(tmp_directory, "#{@file_name}.tex")
        pdf_path = File.join(tmp_directory, "#{@file_name}.pdf")
        FileUtils.mkdir_p tmp_directory

        dest_directory = File.join(Dir.pwd, "assets/images/svg", File.basename(context["page"]["url"], ".*"))
        final_directory = File.join(Dir.pwd, "assets/images/png", File.basename(context["page"]["url"], ".*"))
        dest_path = File.join(dest_directory, "#{@file_name}.svg")
        final_path = File.join(final_directory, "#{@file_name}.png")
        FileUtils.mkdir_p dest_directory
        FileUtils.mkdir_p final_directory

        pdf2svg_path = context["site"]["pdf2svg"]

        # if the file doesn't exist or the tikz code is not the same with the file, then compile the file
        if !File.exist?(tex_path) or !tikz_same?(tex_path, tex_code) or !File.exist?(dest_path)
          File.open(tex_path, 'w') { |file| file.write("#{tex_code}") }
          system("pdflatex -output-directory #{tmp_directory} #{tex_path}")
          system("#{pdf2svg_path} #{pdf_path} #{dest_path}")
          print("#{pdf2svg_path} #{pdf_path} #{dest_path}")
          system("pdf2svg #{pdf_path} #{dest_path}")
          system("inkscape #{dest_path} --export-filename=#{final_path}") 
        end

        # web_dest_path = File.join("/assets/images/svg", File.basename(context["page"]["url"], ".*"), "#{@file_name}.svg")
        web_dest_path = File.join("/assets/images/png", File.basename(context["page"]["url"], ".*"), "#{@file_name}.png")
        # "<center> <embed src=\"#{web_dest_path}\" type=\"image/svg+xml\" /> </center>"
        "<center> <img src=\"#{web_dest_path}\" title=\"#{alt_text}\" alt=\"#{alt_text}\" /> </center>"
      end

      private

      def tikz_same?(file, code)
        File.open(file, 'r') do |file|
          file.read == code
        end
      end

    end
  end
end

Liquid::Template.register_tag('eqn', Jekyll::Tags::Equation)
