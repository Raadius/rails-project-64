# frozen_string_literal: true

require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test 'should create category with valid name' do
    category = Category.new(name: 'Technology')
    assert category.valid?
    assert category.save
  end

  test 'should not create category without name' do
    category = Category.new(name: '')
    assert_not category.valid?
    assert category.errors[:name].any?
    category.valid?
    assert_includes category.errors[:name], I18n.t('activerecord.errors.models.category.attributes.name.blank')
  end

  test 'should not create category with nil name' do
    category = Category.new(name: nil)
    assert_not category.valid?
    assert_includes category.errors[:name], I18n.t('activerecord.errors.models.category.attributes.name.blank')
  end

  test 'should not create two categories with same name' do
    Category.create!(name: 'Technology')
    duplicate_category = Category.new(name: 'Technology')
    assert_not duplicate_category.valid?
    assert_includes duplicate_category.errors[:name],
                    I18n.t('activerecord.errors.models.category.attributes.name.taken')
  end

  test 'should enforce uniqueness case-sensitively' do
    Category.create!(name: 'Technology')
    category = Category.new(name: 'technology')
    assert category.valid?
  end

  test 'should not create category with name shorter than 2 characters' do
    category = Category.new(name: 'A')
    assert_not category.valid?
    assert_includes category.errors[:name], I18n.t('activerecord.errors.models.category.attributes.name.too_short')
  end

  test 'should create category with exactly 2 characters' do
    category = Category.new(name: 'AI')
    assert category.valid?
  end

  test 'should not create category with name longer than 50 characters' do
    category = Category.new(name: 'A' * 51)
    assert_not category.valid?
    assert category.errors[:name].any?
    assert_includes category.errors[:name], I18n.t('activerecord.errors.models.category.attributes.name.too_long')
  end

  test 'should create category with exactly 50 characters' do
    category = Category.new(name: 'A' * 50)
    assert category.valid?
  end

  test 'should have posts association' do
    category = categories(:one)
    assert_respond_to category, :posts
  end

  test 'should destroy dependent posts when category is destroyed' do
    category = categories(:one)
    post = posts(:one)
    post.update!(category: category)

    assert_difference 'Post.count', -1 do
      category.destroy
    end
  end

  test 'should trim whitespace from name' do
    category = Category.new(name: '  Technology  ')
    assert category.valid?
    assert_equal '  Technology  ', category.name
  end
end
