# 説明文の定型文マスタ（docs/07-description-template.md）。
# 商品詳細（03）の「定型文から選ぶ…」で、record / cover の説明文を組み立てるのに使う。
#
# 商品の説明文には文そのものが入り、定型文の id は残らない。そのため編集・削除しても既存の商品は変わらない。
#
# A面・B面・両面だけが違う文は1件にまとめる。jp に {面} を書くと、モーダルで面を選べるようになる。
#   jp      {面}のラベルにダメージ。        → A面のラベルにダメージ。 など
#   en      Some damage on {side} label.   → Some damage on A side label.（A面・B面のとき）
#   en_both Some damage on both side labels.（両面のとき。複数形になるので置き換えでは作れない）
# en_both が空なら、モーダルで「両面」を選べない（「A面のプレイは〜」のように両面では使わない文があるため）
class DescriptionTemplate < ApplicationRecord
  TARGETS = %w[record cover].freeze
  SIDE_JP = '{面}'.freeze
  SIDE_EN = '{side}'.freeze

  validates :target, inclusion: { in: TARGETS }
  validates :category, :jp, :en, presence: true
  validates :position, numericality: { only_integer: true }

  # フロントは説明文を「。」と「.」で文に分け、定型文の文の並びが含まれているかで
  # 「この定型文が使われている」と判定する（front/src/lib/descriptionTemplates.ts）。
  # 末尾の句点が無いと、反映したときに次の文とつながって判定できなくなる。
  validates :jp, format: { with: /。\z/, message: :must_end_with_period_jp }, allow_blank: true
  validates :en, format: { with: /\.\z/, message: :must_end_with_period_en }, allow_blank: true
  validates :en_both, format: { with: /\.\z/, message: :must_end_with_period_en }, allow_blank: true
  validate :side_placeholders_must_match

  before_validation do
    self.category = category&.strip
    self.jp = jp&.strip
    self.en = en&.strip
    self.en_both = en_both&.strip.presence
    self.note = note&.strip.presence
  end

  def side?
    jp.to_s.include?(SIDE_JP)
  end

  # 盤（record）→ ジャケット（cover）の順。商品詳細の欄の並びと同じ
  scope :ordered, -> { in_order_of(:target, TARGETS).order(:position, :id) }

  private

  # 面を選べる定型文（jp に {面}）は、片面用の en に {side} が要る。
  # 面を選ばない定型文に en_both や {side} があっても使われないので、入力の間違いとして止める
  def side_placeholders_must_match
    return if jp.blank? || en.blank?

    if side?
      errors.add(:en, :must_include_side) unless en.include?(SIDE_EN)
      errors.add(:en_both, :must_not_include_side) if en_both&.include?(SIDE_EN)
    else
      errors.add(:en, :side_without_jp) if en.include?(SIDE_EN)
      errors.add(:en_both, :present_without_side) if en_both.present?
    end
  end
end
