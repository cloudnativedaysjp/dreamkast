require 'rails_helper'

RSpec.describe(AdminHelper, type: :helper) do
  describe '#admin_env_label' do
    subject { helper.admin_env_label }

    before { allow(ENV).to receive(:[]).and_call_original }

    context 'when DREAMKAST_NAMESPACE is "dreamkast"' do
      before { allow(ENV).to receive(:[]).with('DREAMKAST_NAMESPACE').and_return('dreamkast') }

      it 'returns Production label' do
        expect(subject).to eq({ name: 'Production', css_class: 'env-label-production' })
      end
    end

    context 'when DREAMKAST_NAMESPACE is "dreamkast-staging"' do
      before { allow(ENV).to receive(:[]).with('DREAMKAST_NAMESPACE').and_return('dreamkast-staging') }

      it 'returns Staging label' do
        expect(subject).to eq({ name: 'Staging', css_class: 'env-label-staging' })
      end
    end

    context 'when DREAMKAST_NAMESPACE is some other value' do
      before { allow(ENV).to receive(:[]).with('DREAMKAST_NAMESPACE').and_return('dreamkast-dev-dk-123-dk') }

      it 'returns Dev label' do
        expect(subject).to eq({ name: 'Dev', css_class: 'env-label-dev' })
      end
    end

    context 'when DREAMKAST_NAMESPACE is not set' do
      before { allow(ENV).to receive(:[]).with('DREAMKAST_NAMESPACE').and_return(nil) }

      it 'returns Dev label' do
        expect(subject).to eq({ name: 'Dev', css_class: 'env-label-dev' })
      end
    end
  end
end
