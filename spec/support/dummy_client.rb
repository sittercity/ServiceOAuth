# Please see LICENSE.txt for copyright and license information.

# This class is an mock Client for testing purposes.
#
class DummyClient < Struct.new(:consumer_key, :consumer_secret)

  DUMMY_KEY    = 'key'
  DUMMY_SECRET = 'shhhh'

  def self.find_by_consumer_key(key)
    if key == DUMMY_KEY
      new(key, DUMMY_SECRET)
    end
  end

end
