# kdevops kconfig integration

kconfig integration was accomplished by integration of kconfig using
[init-kconfig](https://github.com/mcgrof/init-kconfig) as base. The
way in which we can process the `.config` file and expand on it for
writing configuration files is inspired by the way in which kconfig
was embraced in [fio-tests](https://github.com/mcgrof/fio-tests).

Since [init-kconfig](https://github.com/mcgrof/init-kconfig) was used
as base it is important to keep track of the fact that the features
of kconfig from upstream Linux are based on linux-next tag `next-20181002`.
Fortunately, this linux-next tag already carried [kconfig with support for
macro use](https://www.kernel.org/doc/html/latest/kbuild/kconfig-macro-language.html).
