require 'activeadmin-sortable/version'
require 'activeadmin'
require 'rails/engine'

module ActiveAdmin
  module Sortable
    module ControllerActions
      def sortable
        member_action :sort, :method => :post do
          if defined?(::Mongoid::Orderable) &&
            resource.class.included_modules.include?(::Mongoid::Orderable)
              resource.move_to! params[:position].to_i
          else
            resource.insert_at params[:position].to_i
          end
          head 200
        end
      end
    end

    module TableMethods
      HANDLE = '&#x2195;'.html_safe

      def sortable_handle_column(arguments: {})
        column '', :class => "activeadmin-sortable" do |resource|
          sort_url, query_params = resource_path(resource).split '?', 2
          sort_url += "/sort"
          sort_url += "?" + query_params.merge(arguments) if query_params
          order_by, order_dir = params[:order].split '_', 2
          position = resource.send(order_by.to_sym)
          content_tag :span,
                      HANDLE,
                      :class => 'handle',
                      'data-sort-url' => sort_url,
                      'data-position' => position,
                      'data-order' => order_dir
        end
      end
    end

    ::ActiveAdmin::ResourceDSL.send(:include, ControllerActions)
    ::ActiveAdmin::Views::TableFor.send(:include, TableMethods)

    class Engine < ::Rails::Engine
      # Including an Engine tells Rails that this gem contains assets
    end
  end
end


