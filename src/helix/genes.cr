module Helix::Genes
  macro finished
    {%
      # Go through all the subclasses of Species
      Species.all_subclasses.each do |type|
        # Go through all the potentially included modules
        type.ancestors.each do |ancestor|
          raise "Cannot include Helix::Genes to a Helix::Species!" if ancestor == Genes
          # Filter them for being Genes
          if Helix::Genes.ancestors.includes?(ancestor)
            # Check if there is a duplicate
            if (type.ancestors.size-1) != (type.ancestors - [ancestor]).size
              raise "!!!!!WARNING GENE CONFLICT!!!!!\n - Gene #{ancestor} was added multiple times to species #{type}. #{type.ancestors}"
            end
          end
        end
      end
    %}
  end  

  macro included
    raise "This module should never be included. :("
  end
end