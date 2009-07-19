# encoding: utf-8
#
# Text should flow between columns before wrapping to the next page, like a printed newspaper.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

paragraphs = []
paragraphs << <<-ONE
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Vivamus vitae risus vitae lorem iaculis placerat. Aliquam sit amet felis. Etiam congue. Donec risus risus, pretium ac, tincidunt eu, tempor eu, quam. Morbi blandit mollis magna. Suspendisse eu tortor. Donec vitae felis nec ligula blandit rhoncus. Ut a pede ac neque mattis facilisis. Nulla nunc ipsum, sodales vitae, hendrerit non, imperdiet ac, ante. Morbi sit amet mi. Ut magna. Curabitur id est. Nulla velit. Sed consectetuer sodales justo. Aliquam dictum gravida libero. Sed eu turpis. Nunc id lorem. Aenean consequat tempor mi. Phasellus in neque. Nunc fermentum convallis ligula.
ONE
paragraphs << <<-TWO
Suspendisse in nulla. Nunc eu ipsum tincidunt risus pellentesque fringilla. Integer iaculis pharetra eros. Nam ut sapien quis arcu ullamcorper cursus. Vestibulum tempor nisi rhoncus eros. Sed iaculis ultricies tellus. Cras pellentesque erat eu urna. Cras malesuada. Quisque congue ultricies neque. Nullam a nisl. Sed convallis turpis a ante. Morbi eu justo sed tortor euismod porttitor. Aenean ut lacus. Maecenas nibh eros, dapibus at, pellentesque in, auctor a, enim. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aliquam congue pede a ipsum. Sed libero quam, sodales eget, venenatis non, cursus vel, velit. In vulputate.
TWO
paragraphs << <<-THREE
In vehicula. Aenean quam mauris, vehicula non, suscipit at, venenatis sed, arcu. Etiam ornare fermentum felis. Donec ligula metus, placerat quis, blandit at, congue molestie, ante. Donec viverra nibh et dolor. Sed elementum, nunc ac gravida pulvinar, libero ligula vestibulum urna, eget luctus eros ipsum ut velit. Vestibulum at diam. Suspendisse hendrerit. Sed facilisis libero pretium nisl. Morbi eget urna ut mi egestas aliquet. Donec interdum, urna eget semper ultrices, nibh sapien laoreet massa, at laoreet nulla metus sit amet nunc. In augue. Etiam sit amet sapien. Aliquam nulla mi, tincidunt a, ullamcorper pharetra, mollis eu, purus.
Suspendisse auctor nunc a dolor. Donec elit diam, fringilla nec, cursus a, dapibus ut, justo. Maecenas rhoncus lacinia mi. Sed tempus leo in risus. Quisque vitae est. Integer eu mi vel justo lacinia posuere. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec pretium auctor mauris. Cras at risus. Vestibulum ligula purus, venenatis varius, tincidunt aliquam, volutpat ut, felis. In nulla. Suspendisse magna. Fusce ac tortor. Morbi semper hendrerit purus. Donec scelerisque erat quis magna. Vivamus interdum metus at tellus.
Nam molestie suscipit arcu. Sed sed leo non sapien lobortis gravida. Mauris ultricies imperdiet lacus. Maecenas semper sapien in mauris. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nunc euismod odio eget lectus. Vestibulum nonummy pharetra eros. Donec semper venenatis sapien. Phasellus scelerisque lectus quis tortor. Quisque turpis. Etiam rutrum metus eget nisi. Morbi varius ligula id elit. Ut augue.
Nulla arcu est, rhoncus non, eleifend ut, imperdiet vel, magna. Sed pretium pulvinar augue. Sed sit amet nulla eget lacus viverra sollicitudin. Nulla facilisi. Proin sed ipsum vel lacus faucibus dignissim. Nulla purus. Nullam sapien elit, elementum eget, consequat vitae, vehicula cursus, pede. Sed quis leo. Praesent tincidunt convallis ligula. Sed purus eros, malesuada eget, posuere a, convallis suscipit, tellus. Proin tincidunt. Suspendisse leo. Suspendisse risus nisi, hendrerit in, ullamcorper id, porta in, pede. Maecenas lectus mi, congue vitae, ullamcorper vitae, bibendum sit amet, dui. Ut volutpat, nibh scelerisque malesuada bibendum, ipsum felis elementum lacus, nec pretium libero neque ut elit. Duis enim. Fusce arcu nulla, sodales eget, rhoncus sed, fermentum a, erat. Donec vitae mi.
Duis sed nunc a justo egestas tincidunt. Morbi elit. Morbi venenatis fermentum erat. Cras purus orci, imperdiet a, sodales vel, aliquet at, quam. Etiam erat diam, ornare a, nonummy ut, accumsan non, felis. Fusce dignissim. Ut in ligula vitae risus varius viverra. Aenean elit diam, dapibus et, imperdiet in, suscipit at, felis. Curabitur vitae nunc ac mauris tincidunt posuere. Morbi id tortor. Nam sagittis. Sed dolor. Nulla imperdiet magna et lectus. Vivamus sapien diam, condimentum at, ultricies nec, vestibulum sit amet, pede. Nunc non orci vel magna lacinia sodales. In ac nunc vel mauris pharetra pharetra.
Integer quis orci. Nam ultrices, magna nec ullamcorper tincidunt, enim massa semper arcu, sit amet malesuada velit nibh a enim. Phasellus molestie neque eget lorem semper convallis. Duis eget leo. Maecenas commodo vehicula nisi. In viverra massa sed justo. Vestibulum quis velit. Nunc id nulla. Ut eget sem. Nullam congue placerat ante. Mauris ut leo. Cras semper dolor at odio. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
Vivamus quis velit. Aliquam erat volutpat. Praesent malesuada tincidunt purus. Vestibulum quis pede. Praesent luctus, nunc in eleifend fermentum, risus lacus tristique mi, ac mollis metus mi at lectus. Proin tortor. Phasellus erat. Duis cursus nunc non metus. Vivamus hendrerit neque eu felis. Sed interdum metus a enim. Aliquam aliquet vehicula erat. Vivamus tortor neque, ornare ac, cursus id, nonummy ultricies, turpis. Proin tempor nonummy tellus. Praesent metus neque, accumsan eu, tempor sed, porta facilisis, pede. Cras nec nisl in turpis porta congue.
Maecenas sollicitudin feugiat urna. Maecenas tellus. Vestibulum semper, lacus in blandit blandit, neque lectus ullamcorper nulla, at viverra elit justo ac lacus. Proin gravida enim non neque ultricies dictum. In vulputate mattis lacus. In mollis nibh a lacus. Aenean a ipsum. Vivamus egestas adipiscing eros. Cras gravida suscipit risus. Maecenas varius sagittis velit. Phasellus rhoncus risus. Nunc quis urna at neque convallis hendrerit. Mauris metus. Integer eleifend eros nec nunc venenatis ultrices. Curabitur placerat. Nam eros dui, semper vitae, tincidunt quis, tincidunt eu, risus. Ut in pede a neque condimentum feugiat. Maecenas dictum tortor non neque.
THREE



Prawn::Document.generate "column_box.pdf" do
  font "Helvetica", :size => 12
   column_box([0,750], :columns => 2, :spacer => 3, :width => bounds.width, :height => 100) do
      text paragraphs.shift
   end
   
   font "Courier", :size => 10
   column_box([0,600], :width => bounds.width, :height => 100) do
      text paragraphs.shift
   end
   
   font "Times-Roman", :size => 16
   column_box([0,450], :columns => 4, :spacer => font_size * 3, :width => bounds.width) do
      text paragraphs.shift
   end
end

