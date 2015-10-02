class WishService

  module ClassMethods

    def wish(venue_id, user_id)
      unless Venue.exists?(venue_id)
        raise ActiveRecord::RecordNotFound
      end

      wish = Wish.where(venue_id:venue_id, user_id: user_id).first
      if wish ## if you have already done wish, you can't.
        return wish
      end
      return Wish.create!(venue_id:venue_id, user_id:user_id)
    end

    def unwish(venue_id, user_id)
      wish = Wish.where(venue_id:venue_id, user_id:user_id)
      if wish.size == 0
        raise ActiveRecord::RecordNotFound
      else
        if wish.destroy_all
          return true
        else
          raise ActiveRecord::ActiveRecordError
        end
      end
    end

    # sets venue.is_wishlist for list of venues
    def set_is_wishlist(venues, user_id)
      return venues if user_id.nil?

      if venues.respond_to?(:each)
        venue_ids = Wish.where(user_id: user_id).pluck(:venue_id)
        venues.each do |v|
          v.is_wishlist = venue_ids.include?(v.id)
        end
      else
        venues.is_wishlist = is_wish?(venues.id, user_id)
      end
      venues
    end

    # to check if a user did wish or not
    def is_wish?(venue_id, user_id)
      Wish.exists?(venue_id:venue_id, user_id: user_id)
    end

    # Get num of users who wish list a venue
    def num_wishlist_venue (venue_id)
      num = Wish.where(:venue_id => venue_id)
      num.count
    end

    # Total num of users who wish list the venues associated with a deal
    def num_wishlist_deal(deal_id)
      deal_venue = DealVenue.where(:deal_id => deal_id)
      num = 0
      deal_venue.each do |dv|
        wishes = Wish.where(:venue_id => dv.venue_id)
        num = num + wishes.count
      end
      num
    end

  end

  class << self
    include ClassMethods
  end

end