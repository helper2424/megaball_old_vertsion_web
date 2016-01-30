require 'spec_helper'

describe LocaleHelper do
  after :each do
    I18n.locale = I18n.default_locale
  end

  it "should set locale based on user" do
    new_user
    current_user.set(:locale, 'ru')
    set_locale
    expect(I18n.locale).to eq(:ru)

    new_user
    current_user.set(:locale, 'fr')
    set_locale
    expect(I18n.locale).to eq(:fr)
  end

  it "should leave default locale when user is not signed in" do
    set_locale
    expect(I18n.locale).to eq(I18n.default_locale)
  end

  it "should set force locale from params" do
    new_user
    current_user.set(:locale, 'ru')
    params[:locale] = 'fr'

    set_locale
    expect(I18n.locale).to eq(:fr)
  end
end
