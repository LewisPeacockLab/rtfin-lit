module Jekyll
  class Scholar

    class BibliographyTagByApplication < Liquid::Tag
      include Scholar::Utilities
      include ScholarExtras

      def initialize(tag_name, arguments, tokens)
        super

        @config = Scholar.defaults.dup
        
        optparse(arguments)
      end

      def initialize_type_labels()
        @type_labels =
          Hash[{ "neurofeedback" => "Neurofeedback",
                 "clinical" => "Clinical applications",
                 "bci" => "Brain-computer interface",
                 "review" => "Reviews",
                 "methods" => "Methods"
               }]
      end


      def set_type_counts(tc)
        @type_counts = tc
      end

      def render_index(item, ref)
        si = '[' + @prefix_defaults[item.type].to_s + @type_counts.to_s + ']'
        @type_counts = @type_counts - 1
        
        idx_html = content_tag "div class=\"csl-index\"", si
        return idx_html + ref
      end

      def render_header(y)
        ys = content_tag "h2 class=\"csl-year-header\"", y
        ys = content_tag "div class=\"csl-year-icon\"", ys
      end

      def render(context)
        set_context_to context

        # Only select items that are public.
        # items = entries.select { |e| e.public == 'yes' }
        application = @query
        @query = @article
        items = entries
        items = entries.select { |e| e.application == application}

        initialize_prefix_defaults()
        initialize_type_labels()
        set_type_counts(items.size())

        if cited_only?
          items =
            if skip_sort?
              cited_references.uniq.map do |key|
              items.detect { |e| e.key == key }
            end
            else entries.select  do |e|
              cited_references.include? e.key
            end
            end
        end

        items = items[offset..max] if limit_entries?

        bibliography = "" # render_header(@type_labels[application])
        bibliography << items.each_with_index.map { |entry, index|
          reference = bibliography_tag(entry, nil)
          content_tag config['bibliography_item_tag'], reference
          content_tag "li class=\"" + render_ref_img(entry) + "\"", reference
        }.join("\n")


        content_tag config['bibliography_list_tag'], bibliography, :class => config['bibliography_class']
        
      end
    end

  end
end

Liquid::Template.register_tag('bibliography_byapplication', Jekyll::Scholar::BibliographyTagByApplication)
