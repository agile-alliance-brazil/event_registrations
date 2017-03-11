if Rails.env.development?
  task :set_annotation_options do
    Annotate.set_defaults(
      'routes'                  => 'false',
      'position_in_routes'      => 'before',
      'position_in_class'       => 'before',
      'position_in_test'        => 'before',
      'position_in_fixture'     => 'before',
      'position_in_factory'     => 'before',
      'position_in_serializer'  => 'before',
      'show_foreign_keys'       => 'true',
      'show_indexes'            => 'true',
      'simple_indexes'          => 'false',
      'model_dir'               => 'app/models',
      'root_dir'                => '',
      'include_version'         => 'false',
      'require'                 => '',
      'exclude_tests'           => 'true',
      'exclude_fixtures'        => 'false',
      'exclude_factories'       => 'false',
      'exclude_serializers'     => 'false',
      'exclude_scaffolds'       => 'false',
      'exclude_controllers'     => 'true',
      'exclude_helpers'         => 'false',
      'ignore_model_sub_dir'    => 'false',
      'ignore_columns'          => nil,
      'ignore_unknown_models'   => 'false',
      'hide_limit_column_types' => 'integer,boolean,string',
      'skip_on_db_migrate'      => 'false',
      'format_bare'             => 'true',
      'format_rdoc'             => 'false',
      'format_markdown'         => 'false',
      'sort'                    => 'true',
      'force'                   => 'false',
      'trace'                   => 'false',
      'wrapper_open'            => nil,
      'wrapper_close'           => nil
    )
  end

  Annotate.load_tasks
end
