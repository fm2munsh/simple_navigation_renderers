require "spec_helper"

describe SimpleNavigationRenderers do
  it "registers 'bootstrap2' renderer" do
    expect(SimpleNavigation.registered_renderers[:bootstrap2]).to eq SimpleNavigationRenderers::Bootstrap2
  end

  it "registers 'bootstrap3' renderer" do
    expect(SimpleNavigation.registered_renderers[:bootstrap3]).to eq SimpleNavigationRenderers::Bootstrap3
  end
end
