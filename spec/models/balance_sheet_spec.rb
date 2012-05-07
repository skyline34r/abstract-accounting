# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe BalanceSheet do
  before(:all) do
    3.times { Factory(:balance) }
  end
  describe "#all" do
    it "pass options to find method" do
      bs = BalanceSheet.all(date: DateTime.now, include: [:deal])
      bs.each { |balance| balance.association(:deal).loaded?.should be_true }
    end

    it "should accept options without date" do
      bs = BalanceSheet.all(include: [:deal])
      bs.each { |balance| balance.association(:deal).loaded?.should be_true }
    end
  end
end
