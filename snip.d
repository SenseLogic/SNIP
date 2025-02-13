/*
    This file is part of the Snip distribution.

    https://github.com/senselogic/SNIP

    Copyright (C) 2021 Eric Pelzer (ecstatic.coder@gmail.com)

    Snip is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Snip is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Snip.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.conv : to;
import std.file : dirEntries, exists, isFile, mkdirRecurse, readText, write, SpanMode;
import std.path : absolutePath;
import std.stdio : writeln;
import std.string : endsWith, indexOf, lastIndexOf, replace, split, startsWith, strip, stripRight;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

    exit( -1 );
}

// ~~

string GetPhysicalPath(
    string path
    )
{
    version( Windows )
    {
        return `\\?\` ~ path.absolutePath.replace( '/', '\\' ).replace( "\\.\\", "\\" );
    }

    return path;
}

// ~~

string GetLogicalPath(
    string path
    )
{
    return path.replace( '\\', '/' );
}

// ~~

string GetFolderPath(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ 0 .. slash_character_index + 1 ];
    }
    else
    {
        return "";
    }
}

// ~~

string GetFileName(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ slash_character_index + 1 .. $ ];
    }
    else
    {
        return file_path;
    }
}

// ~~

string GetFileLabel(
    string file_path
    )
{
    long
        dot_character_index;
    string
        file_name;

    file_name = GetFileName( file_path );
    dot_character_index = file_name.lastIndexOf( '.' );

    if ( dot_character_index >= 0 )
    {
        return file_name[ 0 .. dot_character_index ];
    }
    else
    {
        return file_name;
    }
}

// ~~

string GetFileExtension(
    string file_path
    )
{
    long
        dot_character_index;
    string
        file_name;

    file_name = GetFileName( file_path );
    dot_character_index = file_name.lastIndexOf( '.' );

    if ( dot_character_index >= 0 )
    {
        return file_name[ dot_character_index .. $ ];
    }
    else
    {
        return "";
    }
}

// ~~

void CreateFolder(
    string folder_path
    )
{
    try
    {
        if ( folder_path != ""
             && folder_path != "/"
             && !folder_path.exists() )
        {
            writeln( "Creating folder : ", folder_path );

            folder_path.GetPhysicalPath().mkdirRecurse();
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't create folder : " ~ folder_path, exception );
    }
}

// ~~

void WriteText(
    string file_path,
    string file_text
    )
{
    CreateFolder( file_path.GetFolderPath() );

    try
    {
        writeln( "Writing file : ", file_path );

        file_path.write( file_text );
    }
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
}

// ~~

string ReadText(
    string file_path
    )
{
    string
        file_text;

    writeln( "Reading file : ", file_path );

    try
    {
        file_text = file_path.readText();
    }
    catch ( Exception exception )
    {
        Abort( "Can't read file : " ~ file_path, exception );
    }

    return file_text;
}

// ~~

string GetComment(
    string file_extension,
    string text
    )
{
    switch ( file_extension )
    {
        case ".cpp", ".cs", ".cxx", ".dart", ".go", ".h", ".hpp", ".hxx", ".java", ".js", ".kt", ".rs", ".scala", ".scss", ".styl", ".swift", "ts" :
        {
            return "//: " ~ text;
        }

        case ".cfg", ".pl", ".py", ".r", ".rb", ".sh", ".yml" :
        {
            return "#: " ~ text;
        }

        case ".lua", ".ps1", ".sql", ".tex" :
        {
            return "--: " ~ text;
        }

        case ".c", ".css" :
        {
            return "/*: " ~ text ~ " */";
        }

        case ".html", ".php", ".svelte", ".svg", ".xml", ".xhtml" :
        {
            return "<!--: " ~ text ~ " -->";
        }

        default :
        {
            return "@: " ~ text;
        }
    }
}

// ~~

void JoinFiles(
    string input_folder_path,
    string output_file_path
    )
{
    string
        input_file_extension,
        input_file_path,
        input_file_text,
        output_file_text;

    writeln( "Reading folder : ", input_folder_path );

    output_file_text = "";

    foreach ( input_folder_entry; input_folder_path.dirEntries( SpanMode.shallow ) )
    {
        if ( input_folder_entry.isFile )
        {
            input_file_path = input_folder_entry.name.GetLogicalPath();

            if ( input_file_path.startsWith( input_folder_path ) )
            {
                input_file_text = input_file_path.ReadText();
                input_file_path = input_file_path[ input_folder_path.length .. $ ];
                input_file_extension = input_file_path.GetFileExtension();

                output_file_text
                    ~= "```\n"
                       ~ input_file_extension.GetComment( input_file_path )
                       ~ "\n"
                       ~ input_file_text
                       ~ "```\n\n";
            }
        }
    }

    output_file_path.WriteText( output_file_text );
}

// ~~

void SplitFile(
    string input_file_path,
    string output_folder_path
    )
{
    bool
        line_is_inside_code;
    long
        first_line_index,
        line_index,
        output_file_path_character_index;
    string
        input_file_text,
        line,
        output_file_text,
        output_file_path;
    string[]
        line_array;

    input_file_text = input_file_path.ReadText();
    line_array = input_file_text.replace( "\r", "" ).replace( "\t", "    " ).split( '\n' );

    line_is_inside_code = false;
    first_line_index = -1;

    output_file_text = "";
    output_file_path = "";

    for ( line_index = 0;
          line_index < line_array.length;
          ++line_index )
    {
        line = line_array[ line_index ].stripRight();

        if ( line.startsWith( "```" ) )
        {
            if ( line_is_inside_code )
            {
                if ( output_file_path != "" )
                {
                    output_file_path.WriteText( output_file_text );
                }

                output_file_path = "";
            }
            else
            {
                output_file_text = "";
                first_line_index = line_index + 1;
            }

            line_is_inside_code = !line_is_inside_code;
        }
        else if ( line_is_inside_code )
        {
            if ( line_index == first_line_index
                 && ( line.startsWith( "@:" )
                      || line.startsWith( "//:" )
                      || line.startsWith( "--:" )
                      || line.startsWith( "#:" )
                      || line.startsWith( "/*:" )
                      || line.startsWith( "<!--:" ) ) )
            {
                if ( line.startsWith( "/*:" ) )
                {
                    line = line.replace( "*/", "" );
                }
                else if ( line.startsWith( "<!--:" ) )
                {
                    line = line.replace( "-->", "" );
                }

                output_file_path_character_index = line.indexOf( ':' ) + 1;
                output_file_path = output_folder_path ~ line[ output_file_path_character_index .. $ ].strip();
            }
            else
            {
                output_file_text ~= line ~ "\n";
            }
        }
    }
}

// ~~

void main(
    string[] argument_array
    )
{
    argument_array = argument_array[ 1 .. $ ];

    if ( argument_array.length == 3
         && argument_array[ 0 ] == "--join"
         && argument_array[ 1 ].GetLogicalPath().endsWith( '/' ) )
    {
        JoinFiles(
            argument_array[ 1 ].GetLogicalPath(),
            argument_array[ 2 ].GetLogicalPath()
            );
    }
    else if ( argument_array.length == 3
         && argument_array[ 0 ] == "--split"
         && argument_array[ 2 ].GetLogicalPath().endsWith( '/' ) )
    {
        SplitFile(
            argument_array[ 1 ].GetLogicalPath(),
            argument_array[ 2 ].GetLogicalPath()
            );
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    snip --join INPUT_FOLDER/ output_text.txt" );
        writeln( "    snip --split input_text.txt OUTPUT_FOLDER/" );

        PrintError( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
