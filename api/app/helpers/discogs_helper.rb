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

  def discogs_format(value)
    [
      value['discogs_release_id'],        # release_id
      value['discogs_price'],             # price
      comments(value),                    # comments
      condition(value['record_grading']), # media_condition
      condition(value['cover_grading']),  # sleeve_condition
      value['SKU'],                       # external_id
      value['weight'],                    # weight
      value['quantity'],                  # quantity
    ]
  end

  private

  def comments(value)
    sleeve = "Sleeve: #{value['cover_grading']}. #{value['cover_description']}"
    vinyl = "Vinyl: #{value['record_grading']}. #{value['record_description_en']}"
    comments = "#{value['cover_grading'].present? ? sleeve + ' ' : ''}#{vinyl}" 
    if value['format'].start_with?('7 inch')
      comments = "#{comments} *we can send you the audio files and the images of both sides. please let us know if you would like."
    end
    comments
  end

  def condition(grading)
    case grading.split('_')[0]
    when 'M'
      'Mint (M)'
    when 'NM', 'EX+'
      'Near Mint (NM or M-)'
    when 'EX', 'EX-', 'VG+'
      'Very Good Plus (VG+)'
    when 'VG'
      'Very Good (VG)'
    when 'VG-、G+'
      'Good Plus (G+)'
    when 'G'
      'Good (G)'
    else
      'Generic'
    end
  end
end