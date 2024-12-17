import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  Future<void> _searchFirestore(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('purchaseAgreements') // 컬렉션 이름
          .where('nameForStorage', isGreaterThanOrEqualTo: query)
          .where('nameForStorage', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      setState(() {
        _searchResults = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'nameForStorage': data['nameForStorage'] ?? 'No Name',
            'pdfUrl': data['pdfUrl'] ?? '', // null 처리
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openPdfViewer(String pdfUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(pdfUrl: pdfUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Records'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchFirestore, // 입력값 변경 시 Firestore 검색
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _searchResults.isNotEmpty
                        ? ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              return ListTile(
                                title: Text(result[
                                    'nameForStorage']), // nameForStorage 표시
                                subtitle: Text('Document ID: ${result['id']}'),
                                trailing: const Icon(Icons.picture_as_pdf),
                                onTap: result['pdfUrl'].isNotEmpty
                                    ? () => _openPdfViewer(result['pdfUrl'])
                                    : () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('PDF URL이 존재하지 않습니다.')),
                                        );
                                      },
                              );
                            },
                          )
                        : const Center(
                            child: Text('No records found.'),
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerScreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _downloadAndSavePdf();
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/temp.pdf';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          localFilePath = filePath;
        });
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF를 불러오지 못했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: localFilePath != null
          ? PDFView(
              filePath: localFilePath, // 로컬 파일 경로 전달
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
