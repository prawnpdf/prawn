module Prawn
  module Chunkable
    def chunk(*a, &b)
      Prawn::Core::Chunk.new(*a, &b)
    end

    def find_chunks(params)
      if params[:command]
        chunks.select { |c| c.command == params[:command] }
      end
    end

    def to_pdf
      rendered = @chunks.map do |chunk| 
        chunk.to_pdf
      end
      
      rendered.join("\n")
    end

    module ClassMethods
      def chunk_methods(*names)
        names.each do |name|
          module_eval %{
            def #{name}(*a, &b)
              chunks << #{name}!(*a, &b)
            end
          }
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
