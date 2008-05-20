$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
                                    
content = <<-EOS
How does
Prawn    deal     with
   white
     space 
     
       and    
       
       line
       breaks?
EOS

poem = <<-EOS
GOOD-BYE

Good-bye, proud world! I'm going home:
Thou art not my friend, and I'm not thine.
Long through thy weary crowds I roam;
A river-ark on the ocean brine,
Long I've been tossed like the driven foam:
But now, proud world! I'm going home.

Good-bye to Flattery's fawning face;
To Grandeur with his wise grimace;
To upstart Wealth's averted eye;
To supple Office, low and high;
To crowded halls, to court and street;
To frozen hearts and hasting feet;
To those who go, and those who come;
Good-bye, proud world! I'm going home.

I am going to my own hearth-stone,
Bosomed in yon green hills alone,--
secret nook in a pleasant land,
Whose groves the frolic fairies planned;
Where arches green, the livelong day,
Echo the blackbird's roundelay,
And vulgar feet have never trod
A spot that is sacred to thought and God.

O, when I am safe in my sylvan home,
I tread on the pride of Greece and Rome;
And when I am stretched beneath the pines,
Where the evening star so holy shines,
I laugh at the lore and the pride of man,
At the sophist schools and the learned clan;
For what are they all, in their high conceit,
When man in the bush with God may meet?
EOS

Prawn::Document.generate("flow.pdf") do |pdf|                  

  pdf.font "Times-Roman"    
  pdf.stroke_line [pdf.bounds.left,  pdf.bounds.top],
                  [pdf.bounds.right, pdf.bounds.top]
  
  pdf.text content, :size => 10    
               
  pdf.bounding_box([100,500], :width => 200, :height => 400) do    
    pdf.stroke_line [pdf.bounds.left,  pdf.bounds.top],
                    [pdf.bounds.right, pdf.bounds.top]
    pdf.text poem, :size => 12  
  end   
  
end