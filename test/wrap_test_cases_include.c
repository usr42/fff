TEST_F(FFFWrapTestSuite, custom_fake_is_set_to_real_function)
{
    ASSERT_EQ(__real_wrapvoidfunc0, __wrap_wrapvoidfunc0_fake.custom_fake);
}

TEST_F(FFFWrapTestSuite, by_default_real_function_is_called)
{
    wrapvoidfunc0();

    ASSERT_EQ(1, wrapvoidfunc0_called);
}

TEST_F(FFFWrapTestSuite, real_function_is_not_called_if_custom_fake_is_set_to_null)
{
    __wrap_wrapvoidfunc0_fake.custom_fake = NULL;

    wrapvoidfunc0();

    ASSERT_EQ(0, wrapvoidfunc0_called);
}

