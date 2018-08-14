class AddingFooterContentToDb < ActiveRecord::Migration[5.2]
  def change
    str = <<-EOF
    <p>
       Powered by
       <a href="https://github.com/NYPL/transcript-editor">Open Transcript Editor</a>
       which was developed by the
       <a href="http://www.nypl.org">New York Public Library</a>
       <a href="/page/about">Find out more.</a>
    </p>
    EOF
    # this will create a footer from the existing string
    # fot the very first time
    # saving as published will create a public_page record too
    page = Page.new(content: str, page_type: 'footer', published: true)
    page.ignore_callbacks = true
    page.save
  end
end
