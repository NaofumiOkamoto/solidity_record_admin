module Api
  # 説明文の定型文マスタの管理（docs/07-description-template.md）。
  # 商品の説明文は定型文を参照しない（文そのものを持つ）ので、削除に参照チェックは無い。
  class DescriptionTemplatesController < ApplicationController
    before_action :set_template, only: %i[update destroy]

    # GET /api/description_templates
    def index
      render json: { description_templates: DescriptionTemplate.ordered.map { |template| serialize(template) } }
    end

    # POST /api/description_templates
    def create
      template = DescriptionTemplate.new(template_params)
      # 順番を空で追加したときは、同じ対象の末尾に置く
      template.position = next_position(template.target) if params.dig(:description_template, :position).blank?

      if template.save
        render json: { description_template: serialize(template) }, status: :created
      else
        render json: { errors: template.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH /api/description_templates/:id
    def update
      if @template.update(template_params)
        render json: { description_template: serialize(@template) }
      else
        render json: { errors: @template.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # POST /api/description_templates/translate
    # 日本語から英語（と英語（両面））を作って返すだけで、保存はしない。画面で確かめてから保存する
    def translate
      jp = params[:jp].to_s.strip
      return render json: { errors: ['日本語を入力してから押してください'] }, status: :unprocessable_entity if jp.blank?

      target = DescriptionTemplate::TARGETS.include?(params[:target]) ? params[:target] : 'record'
      # 編集中の定型文は例から外す（入れると既存の英文をそのまま返す）
      render json: DescriptionTemplateTranslator.new.translate(target: target, jp: jp, exclude_id: params[:id].presence)
    rescue DescriptionTemplateTranslator::Error => e
      render json: { errors: [e.message] }, status: :bad_gateway
    end

    # DELETE /api/description_templates/:id
    def destroy
      @template.destroy
      head :no_content
    end

    private

    def set_template
      @template = DescriptionTemplate.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ['定型文が見つかりません'] }, status: :not_found
    end

    def template_params
      params.require(:description_template).permit(:target, :category, :jp, :en, :en_both, :note, :position)
    end

    def next_position(target)
      (DescriptionTemplate.where(target: target).maximum(:position) || 0) + 10
    end

    def serialize(template)
      template.as_json(only: %i[id target category jp en en_both note position updated_at])
    end
  end
end
