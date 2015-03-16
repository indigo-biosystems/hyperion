class Hash
  def subhash?(hash)
    each_pair.all?{|k, v| hash[k] == v}
  end
end
