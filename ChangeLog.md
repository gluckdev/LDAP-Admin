* Mon Aug 24 2026 Mikhail Artamonov <mikhail.artamonov@edutech-group.ru> - 0.1.4
---------------------
+ Fixed "Division by zero" when opening Start -> Connect (the connection
   dialog never appeared): window sizes were stored as on-screen pixels but
   restored in the form constructor, where the LCL scales them again for the
   monitor DPI - on a HiDPI display the stored connection-list tree width
   doubled on every visit until the LCL refused the bounds (>100000) and
   answered with a bare "Division by zero" box. Window metrics are now stored
   in design-time DPI units, and values that no longer fit the screen fall
   back to the designed default instead of being restored
+ The same double-scaling is fixed for the search window and the template
   (entry editor) window
+ Unhandled errors now also print the exception class to stderr, so a bare
   dialog message can be traced back
+ LDAP errors without a server diagnostic no longer repeat themselves
   ("invalidCredentials (#49): invalidCredentials (#49)")

* Sun Aug 23 2026 Mikhail Artamonov <mikhail.artamonov@edutech-group.ru> - 0.1.3
---------------------
+ Fixed saved connections failing with "Connect: no LDAP server found on
   this network" right after the 0.1.2 configuration migration: FPC's XML
   registry keeps a single root key shared by every TRegistry, so the
   protocol-association check (HKEY_CLASSES_ROOT) redirected all later
   configuration reads away from HKEY_CURRENT_USER and the stored server
   name came back empty

* Tue Aug 18 2026 Mikhail Artamonov <mikhail.artamonov@edutech-group.ru> - 0.1.2
---------------------
+ IPv6 support: host names are resolved via getaddrinfo (IPv4 + IPv6);
   with several addresses each is probed and the first reachable one is
   used, so servers behind IPv6-only routes (e.g. VPNs handing out dead
   synthetic IPv4) now connect
+ Connection errors now show the real failure reason (host unreachable,
   DNS, TLS handshake, server diagnostic) instead of "unknown (#-1)"
+ Unhandled errors show a normal error dialog instead of the scary
   "Press OK to ignore and risk data corruption" box
+ Toolbar icons are 3x bigger (48px); menus and tree keep 16px
+ Fixed garbled (doubly-drawn) text in the attribute value list under
   Qt5: the LCL does not honour DefaultDraw=False, so the custom bold
   drawing overlapped the native text; custom draw disabled
+ Fixed SASL/Kerberos bind failure message crashing when the server
   diagnostic contained '%'
+ Fixed "Chase referrals = off" silently resetting the search size limit
+ Repository moved to github.com/gluckdev/LDAP-Admin: updated install
   one-liner, APT repo URL (gluckdev.github.io), PKGBUILD and .deb metadata;
   re-enabled GitHub Pages so the APT repository works again

* Wed Jan 16 2019 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed Synapse code for OpenSSL 1.1, synalist-code r209 
   https://sourceforge.net/p/synalist/code/HEAD/tree/trunk/ 
   https://www.ap-i.net/mantis/view.php?id=1702&nbn=11
   https://github.com/bmaupin/LDAP-Admin


* Mon Jul 9 2018 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed Startup Connection Session


* Fri Jun 15 2018 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed Targets cbConnections in Copy/Move LDAP Entry


* Thu Dec 28 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed Template AdjustSize
+ Fixed EditEntryForm Template AdjustSize


* Mon Dec 4 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed display format in ConnListFrm, (list,table)


* Sun Nov 26 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed system requirements for SSL/TLS



* Tue Sep 8 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed read/write credentials for Lazarus 1.8 and FPC > 3.0


* Tue Sep 4 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Add How to localize to README


* Thu Sep 3 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed Exception on delete templates
+ Fixed Exception Access violation on close app


* Sat Jul 29 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed drawing templates for Lazarus version > 1.7
+ Fixed .lpi file for publish clean project
+ Fixed deprecated utf8 file utils (fpc version > 3.0)
+ Prepare for new .lrj resource file


* Thu Apr 20 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Version 1.8.2
+ Add reset to menus
+ Fixed deleting of attributes and values in TDBConnection
+ Multivalue template checkbox
+ Fixed Edit popup to use Schema info to determine read only status


* Sun Mar 5 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed MessageDlg
+ Confirm rename entry


* Fri Mar 3 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Add function ldap_bind_s, DIGEST-MD5 SASL method
+ Fixed templates sizeX,Y


* Wed Mar 1 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Add function ldap_get_dn


* Thu Feb 23 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Add ldap_rename_ext_s function [LDAPClasses.pas]
+ Fixed ConvertVariant function [Templates.pas]


* Tue Feb 21 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed export nested list, ConnList form
+ Fixed ldap_stop_tls_s


* Fri Feb 17 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Add LDAP SSL/TLS support from synapse library


* Mon Feb 13 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Adapt changes from Tihomir's SourceForge git, win version 1.7.2.0
+ New storage type 
+ Fixed template changes
+ Fixed ConnList dialog


* Wed Feb 8 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed doubleclik error on ConnList Form, ConnListFrm: Can not focus


* Thu Jan 5 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed binary attribute


* Wed Jan 4 2017 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed export form
+ Fixed function  IsText, Attribute.fDataType
+ Adapt changes from win version 1.7.2.0


* Sat Sep 6 2016 Ivo <ivo.brhel at gmail.com>
---------------------
+ Convert *.pas file LF to CRLF


* Fri Sep 5 2016 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed drawing templates


* Tue Jul 26 2016 Ivo <ivo.brhel at gmail.com>
---------------------
+ Adapt changes from Tihomir's SourceForge git


* Thu Jul 21 2016 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed display the contents lang files


* Wed Jul 20 2016  Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed BinView 2-byte chars


* Fri Jul 15 2016 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed Drag&Drop in LdapTree
+ Fixed TreeDropTarget in Lazarus source
  http://forum.lazarus.freepascal.org/index.php?topic=30263.0 
  see DragDrop.info


* Wed Jul 13 2016 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed drawing Items in ValueListView


* Tue Jul 12 2016 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed BinView


* Mon Jul 11 2016 Ivo <ivo.brhel at gmail.com>
---------------------
+ Fixed Add/Del/Modify attibute in EditEntry Form
+ Fixed add new entry
+ Clean uses in interface units

* Thu Jul 07 2016 Ivo <ivo.brhel at gmail.com>
---------------------
+ Adapt windows version 1.7 to linux
+ Fixed EditEntry Form


* Wed May 08 2016 Ivo <ivo.brhel at gmail.com> 
---------------------
+ Fixed copy/move LDAP entry


* Mon Jun 06 2016 Ivo <ivo.brhel at gmail.com> 
---------------------
+ Add functions ldap_get_values


* Sun May 29 2016 Ivo <ivo.brhel at gmail.com> 
---------------------
+ Enable basic multilang support in main form


* Sat May 28 2016 Ivo <ivo.brhel at gmail.com> 
---------------------
+ Add basic multi lang support


* Tue May 17 2016 Ivo <ivo.brhel at gmail.com> 
---------------------
+ Add LdapAdmin.res
+ Modify .gitignore


* Mon May 16 2016 Ivo <ivo.brhel at gmail.com> 
---------------------
+ First commit 
+ Windows release 1.6.0
