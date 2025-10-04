import { supabase } from './db';

async function test() {
  const { data, error } = await supabase.from('products').select('*');
  
  if (error) {
    console.error('Erro ao buscar produtos:', error);
  } else {
    console.log('Produtos:', data);
  }
}

test();
