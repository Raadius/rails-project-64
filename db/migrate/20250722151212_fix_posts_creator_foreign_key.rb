class FixPostsCreatorForeignKey < ActiveRecord::Migration[7.2]
  def change
    # Эта миграция более не нужна, поскольку данная миграция
    # была поправлена для корректного использования таблицы "users"
    # Не стал удалять, чтоб сохранить историю ведения миграций
  end
end
