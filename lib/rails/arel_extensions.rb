# frozen_string_literal: true

module Rails
  module ArelExtensions
    module Attributes
      def similar_to(text)
        Arel::Nodes::NamedFunction.new(
          'similarity', # included in the pg_trgm PostgreSQL extension
          [self, Arel::Nodes.build_quoted(text.to_s)]
        )
      end
    end
  end
end

module Arel
  module Attributes
    class Attribute
      include Rails::ArelExtensions::Attributes
    end
  end
end
