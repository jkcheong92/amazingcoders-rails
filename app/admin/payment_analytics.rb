ActiveAdmin.register_page "Payment Analytics" do
  menu :parent => "Payment", :priority => 2

  controller do
    def index
      @plan1_name = PlanService.get_plan_names(1)

      analytics_subscription_count
      analytics_premium_subscribers
      analytics_premium_profits
      analytics_subscription_months
    end

    private
    def analytics_premium_subscribers
      all_plan_ids = Plan.pluck(:id)
      premium_count = 0
      @plan_subscribers_series = Array.new
      @addon_subscribers_series = Array.new

      all_plan_ids.each do |id|
        # Plan: Premiums [name, count, drilldown]
        plan_name = PlanService.get_plan_names(id)
        plan_count = PaymentService.count_plan_payments(id)
        premium_count += plan_count
        plan_data = {name: plan_name, y: plan_count, drilldown: plan_name}.to_json
        @plan_subscribers_series.push plan_data

        # Addons for each plan [name, id, data]
        # 1. Data
        addons = PlanService.get_addon_ids(id)
        addon_data_subscribers = Array.new
        addons.each do |a|
          addon = Array.new    # addon consists of [name, subscribers]
          addon.push PlanService.get_addon_names(a)
          addon.push PaymentService.count_addon_payments(a)
          addon_data_subscribers.push addon
        end
        # 2. Pass json
        addon_json = {name: "Addons", id: plan_name, data: addon_data_subscribers}.to_json
        @addon_subscribers_series.push addon_json
      end

      # Plan: Basic plan -> push to first element of array
      basic_data = {name: "Basic Service", y: PaymentService.count_total_payments - premium_count, drilldown: "null"}.to_json
      @plan_subscribers_series.unshift basic_data
    end

    private
    def analytics_premium_profits
      all_plan_ids = Plan.pluck(:id)
      @plan_profits_series = Array.new
      @addon_profits_series = Array.new

      # Basic plan json {name, cost, drilldown}
      basic_plan_json = {name: "Basic Service", y: 0, drilldown: "null"}.to_json
      @plan_profits_series.push basic_plan_json

      all_plan_ids.each do |id|
        # Plan json [name, cost, drilldown]
        plan_name = PlanService.get_plan_names(id)
        plan_cost = PaymentService.get_plan_payments(id).to_f
        plan_json = {name: plan_name, y: plan_cost, drilldown: plan_name}.to_json
        @plan_profits_series.push plan_json

        # Addons for each plan [name, id, data]
        # 1. Get data. [name, costs]
        addons = PlanService.get_addon_ids(id)
        addon_data_profits = Array.new
        addons.each do |a|
          addon = Array.new    # addon consists of [name, costs]
          addon.push PlanService.get_addon_names(a)
          addon.push PaymentService.get_addon_payments(a).to_f
          addon_data_profits.push addon
        end
        # Pass json
        addon_json = {name: "Addons", id: plan_name, data: addon_data_profits}.to_json
        @addon_profits_series.push addon_json
      end
    end

    # Generating subscription count for the past 12 months
    private
    def analytics_subscription_count
      @deal_subscription_count = Array.new    # For y axis
      @months = Array.new                # For x axis
      for i in (0..11).to_a.reverse
        date = Date.today.beginning_of_month.months_ago(i)
        @deal_subscription_count.push PaymentService.count_active_premiums(date, 1)
        @months.push date.strftime("%B")
      end
    end

    # Get months of subscription for each premium service
    private
    def analytics_subscription_months
      all_plan_ids = Plan.pluck(:id)
      @plan_months_series = Array.new
      @addon_months_series = Array.new

      all_plan_ids.each do |id|
        # Plan json [name, months, drilldown]
        plan_name = PlanService.get_plan_names(id)
        plan_months = PaymentService.get_plan_months(id).to_i
        plan_json = {name: plan_name, y: plan_months, drilldown: plan_name}.to_json
        @plan_months_series.push plan_json

        # Addons for each plan [name, id, data]
        # 1. Get data. [name, months]
        addons = PlanService.get_addon_ids(id)
        addon_data_months = Array.new
        addons.each do |a|
          addon = Array.new    # addon consists of [name, month]
          addon.push PlanService.get_addon_names(a)
          addon.push PaymentService.get_addon_months(a)
          addon_data_months.push addon
        end
        # Pass json
        addon_json = {name: "Addons", id: plan_name, data: addon_data_months}.to_json
        @addon_months_series.push addon_json
      end

    end
  end

  content do
    render partial: 'admin/analytics_payment'
  end

end