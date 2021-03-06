ActiveAdmin.register Item do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
	permit_params :artist_id, :item_name, :label, :release_date, :price, :category_id, :image, item_genres_attributes: [:id, :genre_id, :_destroy], stock_attributes: [:quantity, :_destroy], tracks_attributes: [:id, :artist_id, :disc_num, :track_order, :song_title, :song_time, :_destroy]

	menu label: "商品情報", priority: 2

	controller do
		def scoped_collection
			Item.includes(:item_genres)
		end
	end

	index do
		column :item_name
		column :artist_id do |item|
			Artist.where(id: Artist.where(id: item.id).all.pluck(:id)).all.pluck(:artist_name).join(', ')
		end
		# ロードが遅くなるので一覧にはジャケット画像は表示しない
		# column :image do |img|
		# 	attachment_image_tag(img, :image, :fill, 100, 100)
		# end
		column :label
		column :release_date
		column :price
		actions
	end

	form(:html => { :multipart => true }) do |f|
		f.inputs "アイテム詳細" do
			f.input :item_name, :label => '商品名'
			f.input :artist_id, :label => 'アーティスト名', :as => :select, :collection => Artist.all.map{|u| ["#{u.artist_name}", u.id]}
			f.input :label, :label => 'レーベル名'
			f.input :release_date, :label => 'リリース日', :as => :date_picker
			f.input :price, :label => '定価'
			f.input :category_id, :label => 'カテゴリ', :as => :select, :collection => Category.all
			f.attachment_field :image

			f.has_many :item_genres do |ig|
				ig.input :genre_id, :label => 'ジャンル', :as => :select, :collection => Genre.all
				ig.input :_destroy, :as => :boolean, :required => false, :label => '削除する'
			end

			f.has_many :tracks do |t|
				t.input :artist_id, :label => 'アーティスト名', :as => :select, :collection => Artist.all.map{|u| ["#{u.artist_name}", u.id]}
				t.input :disc_num, :label => 'ディスクNo.'
				t.input :track_order, :label => '曲順'
				t.input :song_title, :label => '曲名'
				t.input :song_time, :label => '収録時間'
				t.input :_destroy, :as => :boolean, :required => false, :label => '削除する'
			end

			f.inputs "在庫", :for => [:stock, f.object.stock || Stock.new] do |s|
				s.input :quantity, :label => '在庫数'
			end
			f.actions
		end
	end

	show do |i|
		attributes_table do
			row :artist
			row :item_name
			row :label
			row :release_date
			row :price
			row :category
			row :image do
				attachment_image_tag(i, :image, :fill, 300, 300)
			end
		end

		panel 'ジャンル' do
			attributes_table_for i.item_genres do
				row :genre
			end
		end

		panel '曲' do
			attributes_table_for i.tracks do
				row :artist
				row :disc_num
				row :track_order
				row :song_title
				row :song_time
			end
		end

		panel '在庫' do
			attributes_table_for i.stock do
				row :quantity
			end
		end
	end

end
