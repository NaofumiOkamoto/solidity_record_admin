module DiscogsHelper

  def discogs_header
    [
      'release_id',
      'price',
      'comments',
      'media_condition',
      'sleeve_condition',
      'external_id',
      'weight',
      'quantity',
    ]
  end

  def discogs_format(value, genre)
    [
      value['discogs_release_id'],        # release_id
      "%.15g"%value['discogs_price'],             # price
      comments(value),                    # comments
      discogs_condition(value['record_grading']), # media_condition
      discogs_condition(value['cover_grading']),  # sleeve_condition
      value['SKU'],                       # external_id
      value['weight'],                    # weight
      value['quantity'],                  # quantity
    ]
  end

  private

  def comments(value)
    sleeve = "Cover: #{value['cover_grading']&.gsub('_', '~')}. #{value['cover_description']}"
    vinyl = "Record: #{value['record_grading']&.gsub('_', '~')}. #{value['record_description_en']}"
    comments = "#{value['cover_grading'].present? ? sleeve + ' ' : ''}#{vinyl}" 
    if value['item_condition'] == 'Used'
      comments = "#{comments} *We can send you the audio files and the images of both sides. Please let us know if you would like."
    end
    comments
  end

  def discogs_condition(grading)
    case grading.split('_')[0]
    when 'M'
      'Mint (M)'
    when 'NM', 'EX+'
      'Near Mint (NM or M-)'
    when 'EX', 'EX-', 'VG+'
      'Very Good Plus (VG+)'
    when 'VG'
      'Very Good (VG)'
    when 'VG-', 'G+'
      'Good Plus (G+)'
    when 'G'
      'Good (G)'
    else
      'Generic'
    end
  end
end