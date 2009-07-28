require File.dirname(__FILE__) + '/spec_helper'

describe XmlComparer do
  
  describe "result methods" do
    before(:all) do
      @comparer = XmlComparer.new
    end
    
    describe "missing nodes" do
      it "should include nodes that are not present in the sample" do
        target = "<xml><node></node></xml>"
        sample = "<xml></xml>"
        @comparer.compare(target, sample)
        @comparer.missing_nodes.first.to_xml.should == "<node/>"
        @comparer.missing_nodes.length.should == 1
      end
      
      it "should not contain superfluous nodes" do
         target = "<xml></xml>"
         sample = "<xml><node/></xml>"
         @comparer.compare(target, sample)
         @comparer.missing_nodes.should be_empty
      end
    end

    describe "different nodes" do
      it "should include nodes with different text values" do
        target = "<xml><node>Text</node></xml>"
        sample = "<xml><node>OtherText</node></xml>"
        @comparer.compare(target, sample)
        @comparer.different_nodes.first[0].to_s.should == "Text"
        @comparer.different_nodes.first[1].to_s.should == "OtherText"
        @comparer.different_nodes.length.should == 1
      end
      
      it "should include nodes with different attributes" do
        target = "<xml><node></node></xml>"
        sample = '<xml><node attr="value"></node></xml>'
        @comparer.compare(target, sample)
        @comparer.different_nodes.first[0].to_s.should == "<node/>"
        @comparer.different_nodes.first[1].to_s.should == '<node attr="value"/>'
        @comparer.different_nodes.length.should == 1
      end
    end
    
    describe "superfluous nodes" do
      it "should include nodes that are existing in the sample but not in the target" do
         target = "<xml></xml>"
         sample = "<xml><node/></xml>"
         @comparer.compare(target, sample)
         @comparer.superfluous_nodes.first.to_s.should == "<node/>"
      end
      
      it "should not contain missing nodes" do
         target = "<xml><node/></xml>"
         sample = "<xml></xml>"
         @comparer.compare(target, sample)
         @comparer.superfluous_nodes.should be_empty
      end
      
    end
  end
  
  describe "compare" do
    before(:all) do
      @comparer = XmlComparer.new
    end
    
    describe "nodes" do
      it "should return true if the document is equal" do
        target = "<xml><node></node></xml>"
        sample = "<xml><node></node></xml>"
        @comparer.compare(target, sample).should be_true
      end
      
      it "should return false if different number of same nodes are present" do
        target = "<xml><col><node></node></col></xml>"
        sample = "<xml><col><node></node><node></node></col></xml>"
        @comparer.compare(target, sample).should be_false
      end

      it "should return true if the document contain the same nodes in another order" do
        target = "<xml><node1></node1><node2></node2></xml>"
        sample = "<xml><node2></node2><node1></node1></xml>"
        @comparer.compare(target, sample).should be_true
      end

      it "should return false if the document contain not the same nodes" do
        target = "<xml><node1></node1></xml>"
        sample = "<xml><node2></node2></xml>"
        @comparer.compare(target, sample).should be_false
      end

      it "should return false if target has more nodes" do
        target = "<xml><node1></node1><node2></node2></xml>"
        sample = "<xml><node2></node2></xml>"
        @comparer.compare(target, sample).should be_false
      end

      it "should return false if target has less nodes" do
        target = "<xml><node2></node2></xml>"
        sample = "<xml><node1></node1><node2></node2></xml>"
        @comparer.compare(target, sample).should be_false
      end
      
      it "should return false if nodes have different attributes" do
        target = '<xml><node attr="value"></node></xml>'
        sample = '<xml><node other_attr="value"></node></xml>'
        @comparer.compare(target, sample).should be_false
      end
      
      it "should return false if nodes have different values in attributes" do
        target = '<xml><node attr="value"></node></xml>'
        sample = '<xml><node attr="other_value"></node></xml>'
        @comparer.compare(target, sample).should be_false
      end
    end
    
    describe "text nodes" do
      it "should return true if document only contains other spaces between nodes" do
        target = "<xml><node></node></xml>"
        sample = "<xml>
                  <node></node>
                  </xml>"
        @comparer.compare(target, sample).should be_true
      end

      it "should return false if node contains other text" do
        target = '<xml><parent><node>Text</node></parent></xml>'
        sample = '<xml><parent><node>Other Text</node></parent></xml>'
        @comparer.compare(target, sample).should be_false
      end

      it "should return true if node contains same text" do
        target = "<xml><node>Text</node></xml>"
        sample = "<xml><node>Text</node></xml>"
        @comparer.compare(target, sample).should be_true
      end
    end
    
  end
  
  describe "show messages" do
    describe "disabled" do
      it "should not print anything" do
        out = capture_io do
          XmlComparer.new().compare("<bla></bla>", "<foo></foo>")
        end
        out.should_not include('Following nodes are')
      end
    end
    
    describe "enabled" do
      before(:each) do
        @comparer = XmlComparer.new(:show_messages => true)
      end
      it "should show missing nodes" do
        out = capture_io do
          @comparer.compare("<bla><node></node></bla>", "<bla></bla>")
        end
        out.should include("Following nodes are missing:\n<node/>")
      end
      it "should show missing superfluous nodes" do
        out = capture_io do
          @comparer.compare("<bla></bla>", "<bla><node></node></bla>")
        end
        out.should include("Following nodes are superfluous:\n<node/>")
      end
      
      it "should show different nodes" do
        out = capture_io do
          @comparer.compare("<bla><node></node></bla>", '<bla><node attr="value"></node></bla>')
        end
        out.should include("Following nodes are different:\n<node/>")
      end
      
    end
  end
  
  describe "custom matcher option" do
    it "should return true if node matches conditions in custom matcher rule" do
      target = "<bla><node-id>2</node-id></bla>"
      sample = "<bla><node-id>1</node-id></bla>"
      comparer = XmlComparer.new(:custom_matcher => lambda {|node|
        node.parent.name.include?("id") && node.text.match(/\d+/)})
      comparer.compare(target, sample).should be_true
    end
  end
end
