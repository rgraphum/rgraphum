# encoding: utf-8

require 'matrix'
require 'inline'

class TfIdf

  inline do |builder|
    builder.include "<math.h>"
    builder.add_compile_flags "-fopenmp"
    builder.c <<-EOF 

    VALUE tf_idf( VALUE ary ){
      int i,j,k;
      int m = RARRAY_LEN(ary);
      int n = RARRAY_LEN(rb_ary_entry(ary,0));

      float words_amount;
      float non_word;
      float idfT;

      VALUE tf_idf     = rb_ary_new();
      VALUE tf_idf_ary = rb_ary_new();

      /* tf-idf and output*/
      for( i=0; i<m; i++){

        /* tf base */
        words_amount = 0.0;
        for( j=0; j<n; j++){
          words_amount = words_amount + FIX2INT( rb_ary_entry(rb_ary_entry(ary,i),j) );
        }
        
        tf_idf = rb_ary_new();
        for( j=0; j<n; j++){
          non_word = 0.0;
          for( k=0; k<m; k++){
            if( FIX2INT( rb_ary_entry(rb_ary_entry(ary,k),j)) == 0 ){
              non_word = non_word + 1;
            } 
          }
          idfT = log( m / ( m - non_word ) );
          rb_ary_push( tf_idf, DBL2NUM( ( FIX2INT(rb_ary_entry(rb_ary_entry(ary,i),j)) / words_amount ) * idfT ));
        }   
        rb_ary_push( tf_idf_ary, tf_idf );
      }

      return tf_idf_ary;         
    }
    EOF
  end
end
