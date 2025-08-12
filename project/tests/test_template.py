
import nswi177.templater as tpl

def test_trivial_template_rendering():
    env = tpl.get_jinja_environment('.', False)
    template = env.from_string('{{ data }}')
    assert template.render({'data': 'Hello!'}) == 'Hello!'

def test_filter_replacere():
    env = tpl.get_jinja_environment('.', False)
    template = env.from_string(
        '{{ data|replacere("<LAB:([01][0-9])>","/nswi177/labs/\\\\1") }}'
    )
    assert template.render({'data': 'As seen in <LAB:12> or <LAB:01>.'}) \
        == 'As seen in /nswi177/labs/12 or /nswi177/labs/01.'

