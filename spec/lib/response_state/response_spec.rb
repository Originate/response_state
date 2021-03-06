require 'spec_helper'

module ResponseState
  describe Response do
    subject(:response) { Response.new(state, message, context, valid_states) }
    let(:state) { :success }
    let(:message) { nil }
    let(:context) { nil }
    let(:valid_states) { [:success, :failure] }
    before { Response.instance_variable_set :@class_valid_states, nil }

    it 'yields when sent :success with a state of :success' do
      expect { |b| response.success(&b) }.to yield_control
    end

    it 'does not yield when sent :failure with a state of :success' do
      expect { |b| response.failure(&b) }.not_to yield_control
    end

    context 'when initialized with a message' do
      let(:message) { double(:message) }

      specify { expect(response.message).to eq message }

      context 'when additionally initialized with a context' do
        let(:context) { double(:context) }

        specify { expect(response.context).to eq context }

        context 'when additionally initiaized with a set of valid states' do
          let(:valid_states) { [:success, :failure] }

          it 'yields when sent :success with a state of :success' do
            expect { |b| response.success(&b) }.to yield_control
          end

          it 'does not yield when sent :failure with a state of :success' do
            expect { |b| response.failure(&b) }.not_to yield_control
          end

          it 'throws method missing exception if sent a non-valid state' do
            expect { |b| response.foo(&b) }.to raise_exception
          end

          it 'reflects the valid_states' do
            expect(response.valid_states).to eq [:success, :failure]
          end

          context 'when initialized with an invalid state' do
            let(:state) { :foo }

            it 'raises an exception' do
              expect { response }.to raise_exception('Invalid state of response: foo')
            end
          end
        end
      end
    end

    describe '.valid_states' do
      context 'when set to an array of states' do
        let(:valid_states) { nil }
        before { Response.valid_states(:success, :failure) }

        context 'when the response state is :success' do
          subject(:response) { Response.new(:success) }

          it 'yields when sent :success' do
            expect { |b| response.success(&b) }.to yield_control
          end

          it 'does not yield when sent :failure' do
            expect { |b| response.failure(&b) }.not_to yield_control
          end

          it 'throws method missing exception if sent a non-valid state' do
            expect { |b| response.foo(&b) }.to raise_exception
          end
        end

        context 'when initialized with an invalid state' do
          subject(:response) { Response.new(:foo) }

          it 'raises an exception' do
            expect { response }.to raise_exception('Invalid state of response: foo')
          end
        end

        describe '#valid_states' do
          subject(:response) { Response.new(:success) }

          it 'reflects the valid_states' do
            expect(response.valid_states).to eq [:success, :failure]
          end
        end

        describe '#unhandled_states' do
          subject(:response) { Response.new(:success) }

          context 'when only one state is called' do
            before { response.success {} }

            it 'yields' do
              expect { |b| response.unhandled_states(&b) }.to yield_with_args([:failure])
            end
          end

          context 'when all states are called' do
            before do
              response.success {}
              response.failure {}
            end

            it 'does not yield' do
              expect { |b| response.unhandled_states(&b) }.not_to yield_control
            end
          end
        end
      end
    end
  end
end
