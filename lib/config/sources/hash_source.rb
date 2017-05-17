module Config
  module Sources
    class HashSource
      attr_accessor :hash

      def initialize(hash)
        @hash = hash
      end

      # returns hash that was passed in to initialize
      def load
        hash.is_a?(Hash) ? deep_stringify_keys(hash) : {}
      end

      private

      # Returns a new hash with all keys converted by the block operation.
      # This includes the keys from the root hash and from all
      # nested hashes.
      #
      #  hash = { person: { name: 'Rob', age: '28' } }
      #
      #  hash.deep_transform_keys{ |key| key.to_s.upcase }
      #  # => {"PERSON"=>{"NAME"=>"Rob", "AGE"=>"28"}}
      def deep_transform_keys(hash, &block)
        result = {}
        hash.each do |key, value|
          result[yield(key)] = value.is_a?(Hash) ? deep_transform_keys(value, &block) : value
        end
        result
      end unless method_defined?(:deep_transform_keys)

      # Returns a new hash with all keys converted to strings.
      # This includes the keys from the root hash and from all
      # nested hashes.
      #
      #   hash = { person: { name: 'Rob', age: '28' } }
      #
      #   hash.deep_stringify_keys
      #   # => {"person"=>{"name"=>"Rob", "age"=>"28"}}
      def deep_stringify_keys(hash)
        deep_transform_keys(hash) { |key| key.to_s }
      end unless method_defined?(:deep_stringify_keys)
    end
  end
end
