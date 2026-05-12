require 'rails_helper'

RSpec.describe(AdminHelper, type: :helper) do
  describe '#admin_env_label' do
    subject { helper.admin_env_label }

    context 'when DREAMKAST_NAMESPACE is "dreamkast"' do
      before { stub_const('ENV', ENV.to_hash.merge('DREAMKAST_NAMESPACE' => 'dreamkast')) }

      it 'returns Production label' do
        expect(subject).to eq({ name: 'Production', css_class: 'env-label-production' })
      end
    end

    context 'when DREAMKAST_NAMESPACE is "dreamkast-staging"' do
      before { stub_const('ENV', ENV.to_hash.merge('DREAMKAST_NAMESPACE' => 'dreamkast-staging')) }

      it 'returns Staging label' do
        expect(subject).to eq({ name: 'Staging', css_class: 'env-label-staging' })
      end
    end

    context 'when DREAMKAST_NAMESPACE is some other value' do
      before { stub_const('ENV', ENV.to_hash.merge('DREAMKAST_NAMESPACE' => 'dreamkast-dev-dk-123-dk')) }

      it 'returns Dev label' do
        expect(subject).to eq({ name: 'Dev', css_class: 'env-label-dev' })
      end
    end

    context 'when DREAMKAST_NAMESPACE is not set' do
      before do
        env_without_namespace = ENV.to_hash.except('DREAMKAST_NAMESPACE')
        stub_const('ENV', env_without_namespace)
      end

      it 'returns Dev label' do
        expect(subject).to eq({ name: 'Dev', css_class: 'env-label-dev' })
      end
    end
  end
end
