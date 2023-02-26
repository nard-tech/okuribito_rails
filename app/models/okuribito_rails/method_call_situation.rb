module OkuribitoRails
  class MethodCallSituation < ActiveRecord::Base
    has_many :method_call_logs

    validates :class_name,
              presence: true,
              length: { minimum: 1, maximum: 255 },
              uniqueness: { scope: [:method_symbol, :method_name] }
    validates :method_symbol, presence: true, inclusion: { in: %w(. #) }
    validates :method_name, presence: true, length: { minimum: 1, maximum: 255 }
    validates :called_num,
              presence: true,
              numericality: { only_integer: true, less_than_or_equal_to: 9_999 }

    scope :with_class_name, ->(class_name) { where("class_name LIKE ?", "%#{class_name}%") }
    scope :with_method_name, ->(method_name) { where("method_name LIKE ?", "%#{method_name}%") }
    scope :with_days_passed,
          ->(num) { where("created_at <= ?", Time.zone.today.days_ago(num).end_of_day) }
    scope :with_uncalled_method, -> { where(called_num: 0) }
    scope :with_called_method, -> { where(called_num: 1..Float::INFINITY) }
    scope :group_by_method, -> { group("class_name", "method_symbol", "method_name") }

    class << self
      def search(args)
        mcs = self
        mcs = mcs.with_class_name(args[:class_name]) if args[:class_name].present?
        mcs = mcs.with_method_name(args[:method_name]) if args[:method_name].present?
        mcs = mcs.with_days_passed(args[:days_passed].to_i) if args[:days_passed].present?
        mcs = mcs.with_uncalled_method if args[:uncalled_method].present?
        mcs = mcs.with_called_method if args[:called_method].present?
        mcs
      end

      def register(full_method_name)
        class_name, method_symbol, method_name, *_ = split_full_method_name(full_method_name)
        create(class_name: class_name, method_symbol: method_symbol, method_name: method_name)
      end

      def remove(full_method_name)
        find_by_full_method_name(full_method_name).destroy
      end

      private

      def find_by_full_method_name(full_method_name)
        class_name, method_symbol, method_name, *_ = split_full_method_name(full_method_name)
        find_by(class_name: class_name, method_symbol: method_symbol, method_name: method_name)
      end

      def split_full_method_name(full_method_name)
        full_method_name.split(/\s*(#|\.)\s*/)
      end
    end

    def full_method_name
      [class_name, method_symbol, method_name].join
    end

    def days_monitored
      (Time.zone.today - created_at.to_date).to_i
    end
  end
end
