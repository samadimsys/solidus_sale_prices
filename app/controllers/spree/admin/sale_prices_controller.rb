module Spree
  module Admin
    class SalePricesController < BaseController

      before_filter :load_data

      respond_to :js, :html

      def index
        @sale_prices = @sellable.sale_prices
      end

      def create
        @sale_price = @sellable.put_on_sale params[:sale_price][:value], sale_price_params
        respond_with(@sale_price)
      end

      def destroy
        @sale_price = Spree::SalePrice.find(params[:id])
        @sale_price.destroy
        respond_with(@sale_price)
      end

      private

      def load_data
        @sellable = if params[:variant_id]
                      @variant = Spree::Variant.find_by(slug: params[:variant_id])
                      @product = @variant.product
                      @variant
                    else
                      @product = Spree::Product.find_by(slug: params[:product_id])
                    end

        redirect_to request.referer unless @sellable.present?
      end

      def sale_price_params
        params.require(:sale_price).permit(
            :id,
            :value,
            :currency,
            :start_at,
            :end_at,
            :enabled
        )
      end
    end
  end
end
