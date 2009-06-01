require 'test_helper'

class ContextAssignmentTest < ActiveSupport::TestCase
  test "Default mass assignment works as expected" do
    p = Person.new(:name => 'De Poorter', :first_name => 'Jan', :is_admin => true, :api_key => 'foobarbarbar')
    assert_equal('De Poorter', p.name)
    assert_equal('Jan', p.first_name)
    assert_nil p.is_admin
    assert_nil p.api_key
  end
  
  test "Custom mass assignment works per context" do
    p = Person.new({:name => 'De Poorter', :first_name => 'Jan', :is_admin => true, :api_key => 'foobarbarbar'}, :context => :api)
    assert_nil p.name
    assert_nil p.first_name
    assert_nil p.is_admin
    assert_equal 'foobarbarbar', p.api_key
  end
  
  test "Custom mass assignment works per context on update_attributes" do
    p = Person.new
    p.update_attributes({:name => 'De Poorter', :first_name => 'Jan', :is_admin => true, :api_key => 'foobarbarbar'}, :context => :backoffice)
    assert_equal('De Poorter', p.name)
    assert_equal('Jan', p.first_name)
    assert p.is_admin
    assert_nil p.api_key
  end
  
  test "Custom mass assignment works per context on update_attributes!" do
    p = Person.new
    p.update_attributes!({:name => 'De Poorter', :first_name => 'Jan', :is_admin => true, :api_key => 'foobarbarbar'}, :context => :backoffice)
    assert_equal('De Poorter', p.name)
    assert_equal('Jan', p.first_name)
    assert p.is_admin
    assert_nil p.api_key    
  end
  
  test "Custom mass assignment works on attributes=" do
    p = Person.new
    p.send('attributes=', {:name => 'De Poorter', :first_name => 'Jan', :is_admin => true, :api_key => 'foobarbarbar'}, :context => :backoffice)
    assert_equal('De Poorter', p.name)
    assert_equal('Jan', p.first_name)
    assert p.is_admin
    assert_nil p.api_key
  end
  
  test "Custom mass assignment works with create" do
    p = Person.create({:name => 'De Poorter', :first_name => 'Jan', :is_admin => true}, :context => :backoffice)
    assert_equal('De Poorter', p.name)
    assert_equal('Jan', p.first_name)
    assert p.is_admin
    assert_nil p.api_key
  end

  test "Custom mass assignment works with create!" do
    p = Person.create({:name => 'De Poorter', :first_name => 'Jan', :is_admin => true}, :context => :backoffice)
    assert_equal('De Poorter', p.name)
    assert_equal('Jan', p.first_name)
    assert p.is_admin
    assert_nil p.api_key
  end
  
  test "Using an unknown context raises an error" do
    assert_raise(RuntimeError) { Person.new({:name => 'Jan'}, :context => :unknown)}
  end
end
