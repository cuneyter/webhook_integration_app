require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject(:user) { build(:user) }

    context 'with email_address' do
      it { is_expected.to validate_presence_of(:email_address) }
      it { is_expected.to validate_uniqueness_of(:email_address).case_insensitive }
      it { is_expected.to allow_value('user@example.com').for(:email_address) }
      it { is_expected.to allow_value('user.name+tag@example.co.uk').for(:email_address) }
      it { is_expected.not_to allow_value('user@example').for(:email_address) }
      it { is_expected.not_to allow_value('user').for(:email_address) }
      it { is_expected.not_to allow_value('@example.com').for(:email_address) }
      it { is_expected.not_to allow_value('user@.com').for(:email_address) }
    end

    context 'with password' do
      it 'is valid with a password between 8 and 72 characters' do
        user.password = 'a' * 8
        user.password_confirmation = 'a' * 8
        expect(user).to be_valid

        user.password = 'a' * 72
        user.password_confirmation = 'a' * 72
        expect(user).to be_valid
      end

      it 'is invalid if the password is too short (less than 8 characters)' do
        user.password = 'a' * 7
        user.password_confirmation = 'a' * 7
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('is too short (minimum is 8 characters)')
      end

      it 'is invalid if the password is too long (more than 72 characters)' do
        user.password = 'a' * 73
        user.password_confirmation = 'a' * 73
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('is too long (maximum is 72 characters)')
      end

      it 'is invalid if password is not present on creation' do
        new_user = User.new(email_address: 'test@example.com', password: nil, password_confirmation: nil)
        expect(new_user).not_to be_valid
        expect(new_user.errors[:password]).to include("can't be blank")
      end
    end
  end

  describe 'normalization' do
    it 'normalizes email_address to lowercase and strips whitespace' do
      user = create(:user,
                    email_address: '  TEST@EXAMPLE.COM  ',
                    password: 'password123',
                    password_confirmation: 'password123')
      user.valid? # Trigger normalization
      expect(user.email_address).to eq('test@example.com')
    end
  end
end
