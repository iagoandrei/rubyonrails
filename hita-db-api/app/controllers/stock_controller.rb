class StockController < ApplicationController
  def get_curent_products
    ActiveRecord::Base.establish_connection()

    products = ActiveRecord::Base.connection
    .exec_query("SELECT Cd_material, Descricao, Cd_unidade_medi, Pe_ipi, Classificacao_f
                 FROM esmateri (nolock)
                 WHERE Tipo = 'A' AND Cd_material LIKE '005001%' OR Cd_material LIKE '005002%'
                 ORDER BY Descricao")

    time = (DateTime.current).strftime('%Y%m%d %H:%M')

    if params[:product_type].present? and params[:product_type] == 'reserved'
      product_type_code = '006'
    else
      product_type_code = '002'
    end

    products.each do |product|
      codigo_produto = product['Cd_material']
      precedure_result = ActiveRecord::Base.connection.execute_procedure("dbo.CGPR_EST_CHAMA_POSICAO_ESTOQUE @p_tipoPosicao = 'q', @p_uni_negocio='001', @p_centro_armaz='#{product_type_code}', @p_cd_material='#{codigo_produto}', @p_especif1=null, @p_especif2=null, @p_especif3=null, @p_numeracao=null, @p_lote=null, @p_dt_posicao='#{time}', @p_seqDia=0")
      str = precedure_result[0][""]
      stock = str.split(';')[1].split('=')[1].to_i
      product['estoque'] = stock
    end

    render json: products.as_json
  end

  def product_complete_infos
    ActiveRecord::Base.establish_connection()

    products = ActiveRecord::Base.connection
    .exec_query("SELECT Cd_material, Descricao, Cd_unidade_medi, Pe_ipi, Classificacao_f
                 FROM esmateri (nolock)
                 WHERE Tipo = 'A' AND Cd_material LIKE '005001%' OR Cd_material LIKE '005002%'
                 ORDER BY Descricao")

    products_complete_infos = []

    products.each do |product|
      codigo_produto = product['Cd_material']

      income = ActiveRecord::Base.connection.exec_query("SELECT * FROM escomplm WHERE Cd_material = '#{codigo_produto}'")
      income = income.last ? income.last['Descricao'].rstrip : ''

      characs = ActiveRecord::Base.connection.exec_query("SELECT * FROM esacompa WHERE Material_bem like '#{codigo_produto}' AND Tipo_acomp = 'R'")
      characs = characs.last ? characs.last['Historico'].rstrip : ''

      ncm = product['Classificacao_f']

      current_product = {
        'name': product['Descricao'].rstrip,
        'code': codigo_produto.rstrip,
        'unit': product['Cd_unidade_medi'].remove(' '),
        'ipi': product['Pe_ipi'],
        'income': income,
        'characteristics': characs,
        'ncm': ncm
      }

      products_complete_infos << current_product
    end

    render json: products_complete_infos.as_json, status: :ok
  end

  def product_by_code
    codigo_produto = params[:code]
    time = (DateTime.current).strftime('%Y%m%d %H:%M')

    precedure_result = ActiveRecord::Base.connection.execute_procedure("dbo.CGPR_EST_CHAMA_POSICAO_ESTOQUE @p_tipoPosicao = 'q', @p_uni_negocio='001', @p_centro_armaz='002', @p_cd_material='#{codigo_produto}', @p_especif1=null, @p_especif2=null, @p_especif3=null, @p_numeracao=null, @p_lote=null, @p_dt_posicao='#{time}', @p_seqDia=0")
    str = precedure_result[0][""]
    stock = str.split(';')[1].split('=')[1].to_i

    render json: { product_code: codigo_produto, stock: stock }
  end
end
