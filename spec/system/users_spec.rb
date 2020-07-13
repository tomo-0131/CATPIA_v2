require 'rails_helper'

RSpec.describe "Users", type: :system do
  let!(:user) { create(:user) }
  let!(:admin_user) { create(:user, :admin) }
  let!(:other_user) { create(:user) }
  let!(:shop) { create(:shop, user: user) }
  let!(:other_shop) { create(:shop, user: other_user) }

  describe "ユーザー一覧ページ" do
    context "管理者ユーザーの場合" do
      it "ページネーション、自分以外のユーザーに削除ボタンが表示されることを確認" do
        create_list(:user, 31)
        login_for_system(admin_user)
        visit users_path
        expect(page).to have_css "div.pagination"
        expect(page).to have_link '削除', href: user_path(user) unless admin_user
      end
    end

    context "管理者ユーザー以外の場合" do
      it "ぺージネーション、自分のアカウントのみ削除ボタンが表示されること" do
        create_list(:user, 31)
        login_for_system(user)
        visit users_path
        expect(page).to have_css "div.pagination"
        expect(page).to have_link '削除', href: user_path(user) unless admin_user
      end
    end
  end

  describe "ユーザー登録ページ" do
    before do
      visit signup_path
    end

    context "ページレイアウト" do
      it "「ユーザー登録」の文字列が存在することを確認" do
        expect(page).to have_content 'ユーザー登録'
      end

      it "正しいタイトルが表示されることを確認" do
        expect(page).to have_title full_title('ユーザー登録')
      end
    end

    context "ユーザー登録処理" do
      # it "有効なユーザーでユーザー登録を行うとユーザー登録成功のフラッシュが表示されること" do
      # fill_in "ユーザー名", with: "Example User"
      # fill_in "メールアドレス", with: "user@example.com"
      # fill_in "パ#スワード", with: "password"
      # fill_in "パスワード(確認)", with: "password"
      # click_button "登録する"
      # expect(page).to have_content "CATPIAへようこそ！"
      # end

      it "無効なユーザーでユーザー登録を行うとユーザー登録失敗のフラッシュが表示されること" do
        fill_in "ユーザー名", with: ""
        fill_in "メールアドレス", with: "user@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード(確認)", with: "pass"
        click_button "登録する"
        expect(page).to have_content "ユーザー名を入力してください"
        expect(page).to have_content "パスワード(確認)とパスワードの入力が一致しません"
      end
    end
  end

  describe "プロフィール編集ページ" do
    before do
      login_for_system(user)
      click_link "PROFILE EDIT"
    end

    context "ページレイアウト" do
      it "自己紹介が表示されることを確認" do
        expect(page).to have_content "自己紹介"
      end
    end
  end

  describe "プロフィールページ" do
    context "ページレイアウト" do
      before do
        login_for_system(user)
        create_list(:shop, 10, user: user)
        visit user_path(user)
      end

      it "「プロフィール」の文字列が存在することを確認" do
        expect(page).to have_content 'PROFILE'
      end

      it "正しいタイトルが表示されることを確認" do
        expect(page).to have_title full_title('プロフィール')
      end

      it "ユーザー情報が表示されることを確認" do
        expect(page).to have_content user.name
      end

      it "プロフィール編集ページへのリンクが表示されていることを確認" do
        expect(page).to have_link 'PROFILE EDIT', href: edit_user_path(user)
      end

      it "ねこカフェ投稿の件数が表示されていることを確認" do
        expect(page).to have_content "投稿したねこカフェ #{user.shops.count}件"
      end

      it "ねこカフェ投稿の情報が表示されていることを確認" do
        Shop.take(5).each do |shop|
          expect(page).to have_link shop.name
          expect(page).to have_content shop.description
          expect(page).to have_content shop.recommended_points
          expect(page).to have_content "★"
        end
      end

      it "ねこカフェ投稿のページネーションが表示されていることを確認" do
        expect(page).to have_css ".pagination"
      end
    end
  end
end
