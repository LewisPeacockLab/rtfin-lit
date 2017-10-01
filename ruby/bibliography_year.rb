module Jekyll
  class Scholar
    
    class BibliographyTagYear < Liquid::Tag
      include Scholar::Utilities
      include ScholarExtras

      def initialize(tag_name, arguments, tokens)
        super

        @config = Scholar.defaults.dup
        @config_extras = ScholarExtras.extra_defaults.dup        

        puts @config_extras

        puts @config_extras['parse_extra_fields']
        
        optparse(arguments)

      end

      def initialize_type_counts()
        @type_counts = Hash[{ :neurofeedback => 0,
                              :clinical => 0,
                              :bci => 0,
                              :review => 0,
                              :methods => 0
                            }]

        @type_counts.keys.each { |t|
          # bib = bibliography.query('@*') { |b|
          #   (b.public == 'yes' && b.type == t)
          # }
          bib = bibliography.query('@*') { |b|
            # (b.type == t)
            (b.application == t)
          }
          @type_counts[t] = bib.size
        }
      end

      def initialize_type_order()
        @type_order = Hash[{ :neurofeedback => 0,
                             :clinical => 0,
                             :bci => 0,
                             :review => 0,
                             :methods => 0
                           }]
      end


      def get_entries_by_type(year, type)
        b = bibliography.query('@*') { |item|
          (item.year == year && item.type == type)
        }
      end

      def render_year(y)
        ys = content_tag "h2 class=\"csl-year-header\"", y
        ys = content_tag "div class=\"csl-year-icon\"", ys
      end


      def entries_year(year)
        # b = bibliography.query('@*') { 
        #   |a| (a.year == year && a.public == 'yes')
        # }
        b = bibliography.query('@*') { 
          |a| (a.year == year)
        }
      end

      def initialize_unique_years
        # Get an array of years and then uniquify them.
        items = entries
        arr = Array.new
        items.each { |i| arr.push(i.year.to_s)  }
        @arr_unique = arr.uniq
      end

      def render(context)
        set_context_to context

        # Initialize the number of each type of interest.
        initialize_type_counts()
        initialize_type_order()
        initialize_prefix_defaults()
        initialize_unique_years()

        # Iterate over unique years, and produce the bib.
        bibliography =""
        @arr_unique.each { |y|
          bibliography << render_year(y)
          @type_order.keys.each { |o|
            # items = entries_year(y).select { |e| e.type == o }
            items = entries_year(y).select { |e| e.application == o }
            bibliography << items.each_with_index.map { |entry, index|
              if entry.application == o then 
                reference = bibliography_tag(entry, nil)
                content_tag "li class=\"" + render_ref_img(entry) + "\"", reference
              end
            }.join("\n")
          }.join("\n")
        }.join("")
        return content_tag config['bibliography_list_tag'], bibliography, :class => config['bibliography_class']
      end
    end
  end
end

Liquid::Template.register_tag('bibliography_year', Jekyll::Scholar::BibliographyTagYear)
