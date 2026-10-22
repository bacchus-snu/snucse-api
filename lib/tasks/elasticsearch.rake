namespace :elasticsearch do
  desc 'Recreate the Article, Comment, Profile and Tag indices and bulk-index all records'
  task reindex: :environment do
    batch_size = ENV.fetch('BATCH_SIZE', 500).to_i
    raise ArgumentError, 'BATCH_SIZE must be a positive integer' unless batch_size.positive?

    client = Elasticsearch::Model.client
    client.info

    [Article, Comment, Profile, Tag].each do |model|
      index_name = model.index_name
      model.__elasticsearch__.create_index!(force: true)

      indexed = 0
      model.find_in_batches(batch_size: batch_size) do |records|
        body = records.map do |record|
          { index: { _index: index_name, _id: record.id, data: record.__elasticsearch__.as_indexed_json } }
        end

        response = client.bulk(body: body)
        failures = response['items'].select { |item| item['index']['error'] }
        raise "Bulk indexing failed for #{model.name}: #{failures.first(3).inspect}" if failures.any?

        indexed += records.size
      end

      model.__elasticsearch__.refresh_index!
      puts "#{model.name}: #{indexed} documents indexed into #{index_name}"
    end
  end
end
